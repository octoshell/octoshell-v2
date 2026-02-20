begin
  cluster_id = 5
  year = 2025
  def login_by_node_hours(year, cluster_options)
    results = {}
    Net::SSH.start(cluster_options[:host], cluster_options[:user], key_data: cluster_options[:key]) do |ssh|
      output = ssh.exec! "sudo /opt/slurm/15.08.1/bin/sacct -X  --format=User,JobID,NNodes,Elapsed,Start,State --noheader --parsable2 -S #{year}-01-01 -E  #{year + 1}-01-01"

      output.each_line do |line|
        line.chomp!
        fields = line.split('|')
        next if fields.size < 6

        user, jobid, nnodes_str, elapsed_str, start_time, state = fields
        start_year = start_time.split('-').first
        next unless %w[2024 2025].include? start_year

        next if state.include?('CANCELLED') && elapsed_str == '00:00:00'
        raise "dot in line #{line}" if jobid.include?('.')

        # Parse node count
        nnodes = nnodes_str.to_i

        # Parse elapsed time (format: [[DD-]HH:]MM:SS)
        elapsed_seconds = 0
        if elapsed_str.include?('-')
          days, rest = elapsed_str.split('-')
          elapsed_seconds += days.to_i * 3600 * 24
          elapsed_str = rest
        end

        time_parts = elapsed_str.split(':').map(&:to_i)
        if time_parts.size == 3
          elapsed_seconds += time_parts[0] * 3600 + time_parts[1] * 60 + time_parts[2]
        elsif time_parts.size == 2
          # MM:SS (unlikely but possible)
          elapsed_seconds += time_parts[0] * 60 + time_parts[1]
        else
          raise "Unrecognized time format: #{elapsed_str}"
        end

        elapsed_hours = elapsed_seconds.to_f / 3600.0
        node_hours = nnodes * elapsed_hours

        # Update totals
        results[user] ||= { count: 0, node_hours: 0 }

        results[user][:count] += 1
        results[user][:node_hours] += node_hours
      end
    end
    results
  end

  cluster = Core::Cluster.find(cluster_id)

  node_hours_sql = 'SUM(EXTRACT(EPOCH FROM jobstat_jobs.end_time - jobstat_jobs.start_time)
        / 3600 * jobstat_jobs.num_nodes)'

  octo_stats = Jobstat::Job.where('start_time between :start and :end OR end_time between :start and :end ',
                                  start: DateTime.new(2025, 1, 1), end: DateTime.new(2026, 1, 1))
                           .group('login')
                           .select("login, #{node_hours_sql} AS node_hours, COUNT(id) AS count")
                           .map { |r| [r.login, { node_hours: r['node_hours'], count: r['count'] }] }
                           .to_h

  stats = login_by_node_hours(2025,
                              { host: cluster.host, user: cluster.admin_login, key: cluster.private_key })

  stats.each do |k, v|
    pp [k, v.merge(octo_count: octo_stats[k][:count], octo_node_hours: octo_stats[k][:node_hours])]
  end

  org_logins = Core::Project.joins(:member_owner).preload(%i[members removed_members])
                            .select('core_projects.*, COALESCE(core_projects.organization_id, core_members.organization_id) AS org_id')
                            .to_a
                            .map do |pr|
                              [pr['org_id'], pr.members.map(&:login) | pr.removed_members.map(&:login)]
  end
               .group_by(&:first)
               .transform_values { |v| v.map(&:second).flatten.compact.uniq }
  # pp org_logins
  rows = Core::Organization.all.map do |org|
    next unless org_logins[org.id]

    [
      org.id,
      org.name,
      (org_logins[org.id] & stats.keys).count,
      org_logins[org.id].reduce(0) { |acc, login| acc + (stats[login]&.fetch(:node_hours) || 0) },
      org_logins[org.id].reduce(0) { |acc, login| acc + (stats[login]&.fetch(:count) || 0) },
      (org_logins[org.id] & stats.keys).join(' ')
      # org_logins[org.id].reduce(0) { |acc, login| acc + (octo_stats[login]&.fetch(:node_hours) || 0) },
      # org_logins[org.id].reduce(0) { |acc, login| acc + (octo_stats[login]&.fetch(:count) || 0) }

    ]
  end.compact.select { |r| r[4].positive? }.sort_by(&:first)

  CSV.open('organization_stats.csv', 'w') do |csv|
    csv << ['id',	'название',	'к-во запустившихся логинов', 'узлочасы', 'к-во запусков',
            'запустившиеся логины']

    rows.each { |r| csv << r }
  end

  CSV.open('project_stats.csv', 'w') do |csv|
    csv << ['id', 'название проекта', 'ведущая организация', 'организации, указанные местах работы участников проекта',
            'узлочасы', 'к-во запусков']

    Core::Project.preload([:members, :removed_members, { users: :active_organizations }]).order(:id)
                 .to_a.each do |pr|
                   logins = pr.members.map(&:login) | pr.removed_members.map(&:login)
                   count = logins.reduce(0) { |acc, login| acc + (stats[login]&.fetch(:count) || 0) }
                   next unless count.positive?

                   csv << [
                     pr.id,
                     pr.title,
                     pr.organization&.name || pr.members.detect(&:owner).organization.name,
                     pr.users.map(&:active_organizations).flatten.map(&:name).uniq.join("\n"),
                     logins.reduce(0) { |acc, login| acc + (stats[login]&.fetch(:node_hours) || 0) },
                     count
                     #  logins.reduce(0) { |acc, login| acc + (octo_stats[login]&.fetch(:node_hours) || 0) },
                     #  logins.reduce(0) { |acc, login| acc + (octo_stats[login]&.fetch(:count) || 0) }
                   ]
                 end
  end
rescue StandardError => e
  puts e.inspect
end
