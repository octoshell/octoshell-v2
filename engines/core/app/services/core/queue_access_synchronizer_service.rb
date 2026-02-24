module Core
  class QueueAccessSynchronizerService
    def initialize(cluster, user_params, connection = nil)
      @cluster = cluster
      @user_params = user_params
      @ssh_class = Net::SSH
      @connection_to_cluster = connection
      @should_close_connection = true unless connection
    end

    def run
      open_connection
      create_associations(**@user_params)
    ensure
      close_connection
    end

    private

    def open_connection
      @connection_to_cluster ||= @ssh_class.start(@cluster.host,
                                                  @cluster.admin_login,
                                                  key_data: @cluster.private_key)
    end

    def close_connection
      @connection_to_cluster.close if @should_close_connection
    end

    def create_associations(partition:, user:, account:, max_submit:, max_jobs:)
      run_on_cluster("sudo /usr/octo/add_assoc.sh -p #{partition} -u #{user}" +
      " -a #{account} -s #{max_submit} -j #{max_jobs}")
    end

    def run_on_cluster(command)
      stdout_data = ''
      stderr_data = ''
      exit_code = nil
      @connection_to_cluster.exec!(command) do |_channel, stream, data|
        case stream
        when :stdout
          stdout_data << data
        when :stderr
          stderr_data << data
        end
      end
      @connection_to_cluster.exec!('echo $?') do |_channel, stream, data|
        exit_code = data.to_i if stream == :stdout
      end
      [exit_code, stdout_data.force_encoding('UTF-8'), stderr_data.force_encoding('UTF-8')]
    end
  end
end
