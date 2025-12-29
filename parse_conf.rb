config = YAML.load_file('lim_conf.yml')
CLUSTER_ID = 5
quota = Core::QuotaKind.find_by_api_key!('node_hours')
Core::ResourceControl.delete_all
Core::ResourceControlField.delete_all
Core::QueueAccess.delete_all
Core::ResourceUser.delete_all

notify = File.read('lim_notify.list').split("\n").map do |line|
  arr = line.split(/[\s,]+/)
  [arr[0], arr[1..]]
end.to_h

pp notify

ActiveRecord::Base.transaction do
  Core::Partition.where(cluster_id: CLUSTER_ID).each do |partition|
    partition.update!(max_running_jobs: 6, max_submitted_jobs: 3)
  end
  config.each do |k, h|
    next unless h[:partitions].present? &&  h[:start].present?

    project_ids = (Core::Member.where(login: h[:logins]).map(&:project_id) |
                   Core::RemovedMember.where(login: h[:logins]).map(&:project_id)).uniq
    raise "not one  project(#{project_ids.join(' ')}) for #{h} " if project_ids.count > 1

    project_id = project_ids.first

    access = Core::Access.find_by(cluster_id: CLUSTER_ID, project_id: project_id)

    next unless access

    (notify[k] || []).each do |email|
      user = User.find_by_email(email)
      if user
        access.resource_users.first_or_create!(user: user)
      else
        access.resource_users.first_or_create!(email: email)
      end
    end

    r_c = Core::ResourceControl.new(
      access: access,
      started_at: h[:start]
    )

    h[:partitions].each do |part_name|
      puts part_name.inspect.green
      part = Core::Partition.find_by!(cluster_id: CLUSTER_ID, name: part_name)
      r_c.queue_accesses.new(partition: part, access: access,
                             max_running_jobs: 3, max_submitted_jobs: 6)
    end
    r_c.resource_control_fields.new(
      quota_kind: quota,
      limit: h[:lim]
    )
    r_c.save!
  end
end
