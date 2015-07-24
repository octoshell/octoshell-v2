class Synchronizer
  attr_reader :access, :connection_to_cluster, :project, :cluster

  def initialize(access)
    @access = access
    @project = access.project
    @cluster = access.cluster
    @project_group = access.project_group_name
    @connection_to_cluster = Net::SSH.start(@cluster.host,
                                            @cluster.admin_login,
                                            keys: [mock_ssh_key_path(@cluster.private_key)])
  end

  def mock_ssh_key_path(key)
    path = "/tmp/octo-#{SecureRandom.hex}"
    File.open(path, "wb") { |f| f.write key }
    path
  end

  def run!
    cluster.log("--- START SYNC for project #{project.id}", project)
    cluster.log("\t project state: #{project.state}", project)

    sync_project
    sync_project_members
    sync_quotas if cluster.quotas.any?

    connection_to_cluster.close
    cluster.log("--- END SYNC for project #{project.id}", project)
    access.touch
  end

  def run_on_cluster(command, log_result = true)
    cluster.log("\t command: #{command}", project)
    # result = ""
    # connection_to_cluster.open_channel do |channel|
    #   channel.request_pty do |ch, success|
    #     ch.exec command
    #   end
    #   channel.on_data do |ch, data|
    #     result = data
    #   end
    # end
    result = connection_to_cluster.exec!(command)
    cluster.log("\t  result: #{result}", project) if log_result
    result
  end

  ### - project sync
  def sync_project
    if project.active?
      activate_project!
    end
  end

  def activate_project!
    project_exists_on_cluster? || add_project_group
  end

  def project_exists_on_cluster?
    raw = run_on_cluster("cat /etc/group", false)
    groups_on_cluster = raw.each_line.map do |line|
      line[/(\w+):/, 1]
    end

    groups_on_cluster.include? @project_group
  end

  def add_project_group
    run_on_cluster "sudo /usr/octo/add_group #{@project_group}"
  end
  ### - project sync

  ### - project members sync
  def sync_project_members
    if project.active?
      project.members.each do |member|
        member_state_on_cluster = check_member_state_on_cluster(member)
        if member.allowed?
          cluster.log("\t Access for #{member.login} is allowed", project)
          activate_member(member, member_state_on_cluster)
        elsif  member.suspended?
          cluster.log("\t Access for #{member.login} is suspended", project)
          suspend_member(member, member_state_on_cluster)
        elsif member.denied?
          cluster.log("\t Access for #{member.login} is denied", project)
          deactivate_member(member, member_state_on_cluster)
        end
      end
    elsif project.blocked? || project.suspended?
      project.members.each do |member|
        member_state_on_cluster = check_member_state_on_cluster(member)
        suspend_member(member, member_state_on_cluster)
      end
    else
      project.members.each do |member|
        member_state_on_cluster = check_member_state_on_cluster(member)
        drop_member(member, member_state_on_cluster)
      end
    end
  end

  def activate_member(member, state)
    (state == "active") ||
      ((state == "blocked") ? unblock_member(member) : add_member(member))

    member.credentials.with_state(:active).each do |credential|
      path = upload_credential(credential)
      add_credential(member, path) unless credential_exists_on_cluster?(member, path)
    end
  end

  def deactivate_member(member, state)
    (state == "blocked") || block_member(member)

    member.credentials.with_state(:active).each do |credential|
      path = upload_credential(credential)
      drop_credential(member, path) unless credential_exists_on_cluster?(member, path)
    end
  end

  def suspend_member(member, state)
    (state == "blocked") || block_member(member)
  end

  def drop_member(member, state)
    (state != "closed") && close_member(member)

    member.credentials.with_state(:active).each do |credential|
      path = upload_credential(credential)
      drop_credential(member, path) unless credential_exists_on_cluster?(member, path)
    end
  end

  def check_member_state_on_cluster(member)
    run_on_cluster "sudo /usr/octo/check_user #{member.login} #{@project_group}"
  end

  def add_member(member)
    run_on_cluster "sudo /usr/octo/add_user #{member.login} #{@project_group}"
  end

  def block_member(member)
    run_on_cluster "sudo /usr/octo/block_user #{member.login}"
  end

  def close_member(member)
    run_on_cluster "sudo /usr/octo/del_user #{member.login}"
  end

  def unblock_member(member)
    run_on_cluster "sudo /usr/octo/unblock_user #{member.login}"
  end

  def upload_credential(credential)
    credential_path = mock_ssh_key_path(credential.public_key)
    scp_session = Net::SCP.new(connection_to_cluster)
    scp_session.upload!(credential_path, credential_path)
    credential_path
  end

  def credential_exists_on_cluster?(member, path_to_pub_key)
    out = run_on_cluster "sudo /usr/octo/check_openkey #{member.login} #{path_to_pub_key}"
    out == "found"
  end

  def add_credential(member, path_to_pub_key)
    run_on_cluster "sudo /usr/octo/add_openkey #{member.login} #{path_to_pub_key}"
  end

  def drop_credential(member, path_to_pub_key)
    run_on_cluster "sudo /usr/octo/del_openkey #{member.login} #{path_to_pub_key}"
  end
  ### - project members sync

  def sync_quotas
    # TODO: write qoutas check scripts
    # cluster.log("\t checking quotas....\n")
  end
end
