module Core
  class ClusterStatsError < StandardError; end

  class ClusterStatsService
    SACCT_PATH = '/usr/octo/sacct'

    def self.call(cluster:, start_date:, end_date:, group_by: 'login', period_group: 'none')
      new(cluster, start_date, end_date, group_by, period_group).call
    end

    def initialize(cluster, start_date, end_date, group_by, period_group)
      @cluster = cluster
      @start_date = start_date.to_date
      @end_date = end_date.to_date
      @group_by = group_by
      @period_group = period_group
    end

    def call
      init_accumulators
      fetch_slurm_data
      build_login_entity_map_for_grouping
      finalize_result
    end

    private

    # ===== Fetching data from SLURM via SSH =====

    def fetch_slurm_data
      start_str = @start_date.strftime('%Y-%m-%d')
      end_str   = (@end_date + 1.day).strftime('%Y-%m-%d')

      command = "sudo #{SACCT_PATH} -X " \
                '--format=User,JobID,NNodes,Elapsed,Start,State,Partition ' \
                '--noheader --parsable2 ' \
                "-S #{start_str} -E #{end_str}"

      stdout, stderr = @cluster.execute(command)
      raise ClusterStatsError, "SLURM error: #{stderr}" if stderr.present?

      # Parse sacct output line by line, accumulating directly into target structures
      stdout.each_line do |line|
        accumulate_line(line)
      end
    end

    # ===== Accumulators initialization =====

    def init_accumulators
      @all_logins = Set.new
      @partition_set = Set.new
      @login_entity_map = nil

      if @period_group == 'none'
        # @grouped[group_key] = { total: { node_hours:, job_count: },
        #                          partitions: { 'compute': { node_hours:, job_count: }, ... } }
        @grouped = Hash.new do |h, k|
          h[k] = { total: { node_hours: 0.0, job_count: 0 },
                   partitions: Hash.new { |hh, pk| hh[pk] = { node_hours: 0.0, job_count: 0 } } }
        end
      else
        @periods = generate_periods
        @column_labels = @periods.map(&:last)

        # @cell_map[group_key][period_label] = { total: { node_hours:, job_count: },
        #                                         partitions: { 'compute': {...} } }
        @cell_map = Hash.new do |h, k|
          h[k] = Hash.new do |hh, pk|
            hh[pk] = { total: { node_hours: 0.0, job_count: 0 },
                       partitions: Hash.new { |hsh, part| hsh[part] = { node_hours: 0.0, job_count: 0 } } }
          end
        end
      end
    end

    # ===== Parse one line and accumulate =====

    def accumulate_line(line)
      line.chomp!
      fields = line.split('|')
      return if fields.size < 7

      user, jobid, nnodes_str, elapsed_str, start_time, state, partition = fields

      # Reject child jobs (JobID containing a dot)
      raise ClusterStatsError, "Child job detected (JobID=#{jobid}) in sacct output." if jobid.include?('.')

      # Skip CANCELLED jobs with zero elapsed time
      return if state.include?('CANCELLED') && elapsed_str == '00:00:00'

      nnodes = nnodes_str.to_i
      return if nnodes <= 0

      elapsed_hours = parse_elapsed_to_hours(elapsed_str)
      return if elapsed_hours.nil? || elapsed_hours <= 0

      parsed_start = parse_sacct_time(start_time)
      return if parsed_start.nil?

      part_name = partition.presence || 'unknown'
      @partition_set << part_name
      @all_logins << user

      if @period_group == 'none'
        accumulate_flat(user, part_name, parsed_start, elapsed_hours, nnodes)
      else
        accumulate_periods(user, part_name, parsed_start, elapsed_hours, nnodes)
      end
    end

    # Accumulate into flat structure (no period breakdown).
    # Clips the task time to [@start_date, @end_date] boundaries.
    # Uses login as the key during parsing; regrouping by entity happens in finalize_flat.
    def accumulate_flat(login, partition, parsed_start, elapsed_hours, nnodes)
      task_end = parsed_start + elapsed_hours.hours

      period_start = @start_date.beginning_of_day
      period_end   = @end_date.end_of_day

      eff_start = [parsed_start, period_start].max
      eff_end   = [task_end, period_end].min

      return if eff_start >= eff_end

      duration_hours = (eff_end - eff_start) / 3600.0
      clipped_node_hours = duration_hours * nnodes

      # Use raw login as key during parsing; regrouping happens in finalize_flat
      entry = @grouped[login]
      entry[:total][:node_hours] += clipped_node_hours
      entry[:total][:job_count]  += 1
      part_entry = entry[:partitions][partition]
      part_entry[:node_hours] += clipped_node_hours
      part_entry[:job_count]  += 1
    end

    # Accumulate into period-broken structure.
    # A task belongs entirely to the period in which it started (parsed_start).
    # No clipping across period boundaries — the full task goes to its start period.
    # Uses login as the key during parsing; regrouping happens in finalize_periods.
    def accumulate_periods(login, partition, parsed_start, elapsed_hours, nnodes)
      period_info = find_period_for_start(parsed_start)
      return if period_info.nil?

      _, _, label = period_info
      node_hours = elapsed_hours * nnodes

      cell = @cell_map[login][label]
      cell[:total][:node_hours] += node_hours
      cell[:total][:job_count]  += 1
      part_cell = cell[:partitions][partition]
      part_cell[:node_hours] += node_hours
      part_cell[:job_count]  += 1
    end

    # ===== Finalize result from accumulators =====

    def finalize_result
      partition_columns = @partition_set.to_a.sort

      if @period_group == 'none'
        finalize_flat(partition_columns)
      else
        finalize_periods(partition_columns)
      end
    end

    def finalize_flat(partition_columns)
      # Regroup: merge rows that map to the same entity key.
      # Skip logins that don't map to any entity (nil key).
      merged = {}
      @grouped.each do |login_key, data|
        entity_key = resolve_group_key_for_login(login_key)
        next if entity_key.nil?

        if merged[entity_key]
          existing = merged[entity_key]
          existing[:total][:node_hours] += data[:total][:node_hours]
          existing[:total][:job_count]  += data[:total][:job_count]
          data[:partitions].each do |part, part_data|
            ep = existing[:partitions][part]
            ep[:node_hours] += part_data[:node_hours]
            ep[:job_count]  += part_data[:job_count]
          end
        else
          merged[entity_key] = {
            total: { node_hours: data[:total][:node_hours], job_count: data[:total][:job_count] },
            partitions: data[:partitions].dup
          }
        end
      end

      rows = merged.map do |key, data|
        {
          key: key,
          total: { node_hours: data[:total][:node_hours].round(2), job_count: data[:total][:job_count] },
          partitions: data[:partitions].transform_values do |v|
            { node_hours: v[:node_hours].round(2), job_count: v[:job_count] }
          end
        }
      end.sort_by { |r| -r[:total][:node_hours] }

      total_nh = rows.sum { |r| r[:total][:node_hours] }
      total_jc = rows.sum { |r| r[:total][:job_count] }
      { source: :slurm, partition_columns: partition_columns, rows: rows,
        total: { node_hours: total_nh.round(2), job_count: total_jc } }
    end

    def finalize_periods(partition_columns)
      if @periods.empty?
        return { source: :slurm, columns: [], partition_columns: [], rows: [],
                 total: { node_hours: 0.0, job_count: 0 } }
      end

      # Regroup: merge cells that map to the same entity key.
      # Skip logins that don't map to any entity (nil key).
      merged = {}
      @cell_map.each do |login_key, cells|
        entity_key = resolve_group_key_for_login(login_key)
        next if entity_key.nil?

        if merged[entity_key]
          existing = merged[entity_key]
          cells.each do |label, cell_data|
            ec = existing[label]
            if ec
              ec[:total][:node_hours] += cell_data[:total][:node_hours]
              ec[:total][:job_count]  += cell_data[:total][:job_count]
              cell_data[:partitions].each do |part, part_data|
                ep = ec[:partitions][part]
                ep[:node_hours] += part_data[:node_hours]
                ep[:job_count]  += part_data[:job_count]
              end
            else
              existing[label] = { total: cell_data[:total].dup,
                                  partitions: cell_data[:partitions].dup }
            end
          end
        else
          merged[entity_key] = cells.dup
        end
      end

      rows = merged.map do |key, cells|
        full_cells = {}
        @column_labels.each do |label|
          cell = cells[label]
          if cell
            full_partitions = {}
            partition_columns.each do |part|
              full_partitions[part] = cell[:partitions].fetch(part, { node_hours: 0.0, job_count: 0 })
            end
            full_cells[label] = { total: cell[:total], partitions: full_partitions }
          else
            empty_partitions = {}
            partition_columns.each { |part| empty_partitions[part] = { node_hours: 0.0, job_count: 0 } }
            full_cells[label] = { total: { node_hours: 0.0, job_count: 0 }, partitions: empty_partitions }
          end
        end
        { key: key, cells: full_cells }
      end

      # Sort rows by total node_hours descending
      rows.sort_by! { |r| -r[:cells].values.sum { |c| c[:total][:node_hours] } }

      total_nh = rows.sum { |r| @column_labels.sum { |col| r.dig(:cells, col, :total, :node_hours) || 0 } }
      total_jc = rows.sum { |r| @column_labels.sum { |col| r.dig(:cells, col, :total, :job_count) || 0 } }
      { source: :slurm, columns: @column_labels, partition_columns: partition_columns,
        rows: rows, total: { node_hours: total_nh.round(2), job_count: total_jc } }
    end

    # ===== Helpers =====

    def parse_elapsed_to_hours(elapsed_str)
      elapsed_seconds = 0

      if elapsed_str.include?('-')
        days, rest = elapsed_str.split('-')
        elapsed_seconds += days.to_i * 86_400
        elapsed_str = rest
      end

      time_parts = elapsed_str.split(':').map(&:to_i)

      if time_parts.size == 3
        elapsed_seconds += time_parts[0] * 3600 + time_parts[1] * 60 + time_parts[2]
      elsif time_parts.size == 2
        elapsed_seconds += time_parts[0] * 60 + time_parts[1]
      else
        return nil
      end

      elapsed_seconds / 3600.0
    end

    def parse_sacct_time(time_str)
      Time.zone.parse(time_str)
    rescue StandardError
      nil
    end

    # Resolve the grouping key for a login.
    # For 'login' group_by, returns the login itself.
    # For 'project'/'organization'/'department', looks up via @login_entity_map.
    # Returns nil if the login is not found in the map (row will be excluded).
    def resolve_group_key_for_login(login)
      case @group_by
      when 'login' then login.presence || '(unknown)'
      when 'project', 'organization', 'department'
        @login_entity_map[login]
      end
    end

    # Find the period that contains the given start time.
    def find_period_for_start(parsed_start)
      @periods.find do |ps, pe, _|
        parsed_start >= ps.beginning_of_day && parsed_start <= pe.end_of_day
      end
    end

    def generate_periods
      case @period_group
      when 'month'
        generate_month_periods
      when 'quarter'
        generate_quarter_periods
      end
    end

    def generate_month_periods
      periods = []
      current = @start_date
      while current <= @end_date
        month_end = current.end_of_month
        periods << [current, [month_end, @end_date].min, current.strftime('%Y-%m')]
        current = month_end + 1.day
      end
      periods
    end

    def generate_quarter_periods
      periods = []
      current = @start_date
      while current <= @end_date
        q_end = current.end_of_quarter
        periods << [current, [q_end, @end_date].min, "Q#{(current.month / 3.0).ceil} #{current.year}"]
        current = q_end + 1.day
      end
      periods
    end

    # Строит @login_entity_map после того, как @all_logins полностью собран.
    # Вызывается из call после fetch_slurm_data.
    def build_login_entity_map_for_grouping
      return if @group_by == 'login'

      entity_type = @group_by.to_sym

      projects = Core::Project.preload(:organization, :organization_department,
                                       :members, :removed_members)
                              .to_a

      map = {}
      projects.each do |pr|
        pr_logins = pr.members.map(&:login) | pr.removed_members.map(&:login)
        # Учитываем только те логины, которые есть в sacct
        pr_logins &= @all_logins.to_a
        next if pr_logins.empty?

        key = case entity_type
              when :project
                pr.id_with_title
              when :organization
                pr.organization&.to_s
              when :department
                if pr.organization_department
                  pr.organization_department.full_name
                else
                  "#{pr.organization} (без подразделения)"
                end
              end

        next if key.blank?

        pr_logins.each do |login|
          map[login] = key
        end
      end
      @login_entity_map = map
    end
  end
end
