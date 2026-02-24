module Core
  class NodeHourCounterService
    def initialize(cluster, project_hashes, ssh_class = Net::SSH)
      @cluster = cluster
      @project_hashes = project_hashes
      @ssh_class = ssh_class
    end

    def run
      open_connection
      @project_hashes.map do |h|
        %i[logins start_date partitions].each do |a|
          raise ArgumentError, ":#{a} is not set in hash" if h[a].nil?
        end
        sum_node_hours(h[:logins], h[:start_date], h[:partitions])
      end
    ensure
      close_connection
    end

    private

    def open_connection
      @connection_to_cluster = @ssh_class.start(@cluster.host,
                                                @cluster.admin_login,
                                                key_data: @cluster.private_key)
    end

    def close_connection
      @connection_to_cluster.close
    end

    def jobs_of_users(logins, start_time, partitions)
      logins = logins.join(',')
      partitions = partitions.join(',')
      start_time = start_time.strftime('%Y-%m-%dT%H:%M:%S')

      run_on_cluster "sudo /usr/octo/get_jobs_of_users.sh -u #{logins} -p #{partitions} -d #{start_time}"
    end

    def contains_letters?(str)
      str.match?(/\p{L}/) # \p{L} - любая буква в Unicode
    end

    def sum_node_hours(logins, start_time, partitions)
      _exit_code, stdout, stderr = jobs_of_users(logins, start_time, partitions)
      node_hours = stdout.split("\n").reduce(0) do |sum, row|
        fields = row.split('|')
        if contains_letters?(fields[0]) || contains_letters?(fields[1])
          stderr ||= ''
          stderr += 'Incorrect value for nodehours. Check if everything is okay'
          next sum
        end
        sum + node_hours(fields[0], fields[1])
      end
      [node_hours, stderr]
    end

    def node_hours(nodes, elapsed)
      total_hours = 0

      # if (DD-HH:MM:SS)
      if elapsed.include?('-')
        days, time = elapsed.split('-')
        total_hours += days.to_f * 24
        elapsed = time
      end

      h, m, s = elapsed.split(':').map(&:to_f)
      total_hours += h + m / 60 + s / 3600

      total_hours * nodes.to_f
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
      [exit_code, stdout_data, stderr_data.force_encoding('UTF-8')]
    end
  end
end
