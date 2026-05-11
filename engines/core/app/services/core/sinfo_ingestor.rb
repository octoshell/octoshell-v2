require "set"

module Core
  class SinfoIngestor
    STATES = %w[alloc idle comp drain drng down maint reserved mix].freeze

    # Если в твоей версии Rails unique_by по массиву колонок не работает,
    # замени на реальные имена индексов, например:
    # :index_core_analytics_nodes_on_cluster_id_and_hostname
    # :index_core_analytics_node_states_on_snapshot_id_and_node_id
    NODE_UNIQUE_BY = %i[cluster_id hostname].freeze
    NODE_STATE_UNIQUE_BY = %i[snapshot_id node_id partition_id].freeze

    def initialize(raw_text:, source_cmd: "sinfo -a", parser_version: "v1",
                   quiet: false, cluster_id:, **_)
      @raw            = raw_text.to_s
      @source_cmd     = source_cmd
      @parser_version = parser_version
      @quiet          = quiet
      @cluster_id     = cluster_id
    end

    def call
      raise "empty sinfo output" if @raw.strip.empty?

      with_schema_context do
        with_silenced_ar do
          raise "cluster_id is required" if @cluster_id.blank?

          snapshot_id     = insert_snapshot!
          parsed_lines    = parse_table_lines(@raw)
          partition_names = parsed_lines.map { |h| h[:partition] }.to_set
          hostnames       = parsed_lines.flat_map { |h| h[:hostnames] }.to_set

          part_id = upsert_partitions(partition_names, parsed_lines)
          node_id = upsert_nodes(hostnames)

          rows = []
          parsed_lines.each do |h|
            p_id = part_id[h[:partition]]
            st   = h[:state]
            rsn  = h[:has_reason]

            h[:hostnames].each do |hn|
              n_id = node_id[hn]
              rows << [snapshot_id, n_id, p_id, st, rsn]
            end
          end

          rows = rows.reverse.uniq { |snap_id, node_id, part_id, _s, _r| [snap_id, node_id, part_id] }.reverse
          rows_written = bulk_upsert_node_states(rows)

          {
            snapshot_id:  snapshot_id,
            nodes_total:  hostnames.size,
            rows_written: rows_written,
            partitions:   part_id.size
          }
        end
      end
    end

    private

    def snapshot_model
      Core::Analytics::Snapshot
    end

    def node_model
      Core::Analytics::Node
    end

    def node_state_model
      Core::Analytics::NodeState
    end

    def partition_model
      Core::Partition
    end

    def with_silenced_ar
      return yield unless @quiet

      ar_logger  = ActiveRecord::Base.logger
      app_logger = defined?(Rails) ? Rails.logger : nil
      old_ar  = ar_logger&.level
      old_app = app_logger&.level

      begin
        ar_logger.level  = Logger::WARN if ar_logger
        app_logger.level = Logger::INFO if app_logger
        yield
      ensure
        ar_logger.level  = old_ar if ar_logger
        app_logger.level = old_app if app_logger
      end
    end

    def with_schema_context
      ActiveRecord::Base.connection_pool.with_connection { yield }
    end

    def insert_snapshot!
      now = Time.current

      result = snapshot_model.unscoped.insert_all!(
        [
          {
            cluster_id:     @cluster_id,
            captured_at:    now,
            source_cmd:     @source_cmd,
            raw_text:       @raw,
            parser_version: @parser_version,
            created_at:     now,
            updated_at:     now
          }
        ],
        returning: %w[id]
      )

      result.rows.first.first
    end

    def upsert_partitions(partition_names, _parsed_lines)
      map = {}
      names = partition_names.to_a

      return map if names.empty?

      names.each_slice(500) do |chunk|
        partition_model.unscoped
                       .where(cluster_id: @cluster_id, name: chunk)
                       .pluck(:name, :id)
                       .each do |name, id|
          map[name] = id
        end
      end

      missing = names - map.keys
      return map if missing.empty?

      missing.each_slice(200) do |chunk|
        partition_model.unscoped.insert_all!(
          chunk.map do |name|
            {
              cluster_id: @cluster_id,
              name:       name
            }
          end
        )

        partition_model.unscoped
                       .where(cluster_id: @cluster_id, name: chunk)
                       .pluck(:name, :id)
                       .each do |name, id|
          map[name] = id
        end
      end

      map
    end

    def upsert_nodes(hostnames)
      map = {}
      return map if hostnames.empty?

      hostnames.each_slice(500) do |chunk|
        now = Time.current

        payload = chunk.map do |hn|
          prefix, _number = split_prefix_number(hn)

          {
            cluster_id: @cluster_id,
            hostname:   hn,
            prefix:     prefix,
            created_at: now,
            updated_at: now
          }
        end

        node_model.unscoped.upsert_all(payload, unique_by: NODE_UNIQUE_BY)

        node_model.unscoped
                  .where(cluster_id: @cluster_id, hostname: chunk)
                  .pluck(:hostname, :id)
                  .each do |hostname, id|
          map[hostname] = id
        end
      end

      map
    end

    def bulk_upsert_node_states(rows)
      return 0 if rows.empty?

      node_ids = rows.map { |(_snap_id, node_id, _p, _s, _r)| node_id }.uniq
      current_states = load_current_states(node_ids)

      rows_to_insert = []
      ids_to_close   = []

      rows.each do |snap_id, node_id, part_id, state, has_reason|
        cur = current_states[[node_id, part_id]]

        if cur.nil?
          rows_to_insert << [snap_id, node_id, part_id, state, has_reason]
        elsif cur[:state] == state && cur[:has_reason] == has_reason
          next
        else
          ids_to_close << cur[:id]
          rows_to_insert << [snap_id, node_id, part_id, state, has_reason]
        end
      end

      close_node_states(ids_to_close) unless ids_to_close.empty?
      insert_new_node_states(rows_to_insert)
    end

    def load_current_states(node_ids)
      return {} if node_ids.empty?

      map = {}

      node_ids.each_slice(5_000) do |chunk|
        node_state_model.unscoped
                        .where(cluster_id: @cluster_id, valid_to: nil, node_id: chunk)
                        .pluck(:id, :node_id, :partition_id, :state, :has_reason)
                        .each do |id, node_id, part_id, state, has_reason|
          map[[node_id, part_id]] = {
            id:         id,
            state:      state,
            has_reason: has_reason
          }
        end
      end

      map
    end

    def close_node_states(ids)
      ids.each_slice(5_000) do |chunk|
        now = Time.current

        node_state_model.unscoped
                        .where(id: chunk)
                        .update_all(valid_to: now, updated_at: now)
      end
    end

    def insert_new_node_states(rows)
      return 0 if rows.empty?

      count = 0

      rows.each_slice(5_000) do |chunk|
        now = Time.current

        payload = chunk.map do |snap_id, node_id, part_id, state, has_reason|
          {
            cluster_id:   @cluster_id,
            snapshot_id:  snap_id,
            node_id:      node_id,
            partition_id: part_id,
            state:        state,
            substate:     nil,
            has_reason:   has_reason,
            valid_from:   now,
            valid_to:     nil,
            created_at:   now,
            updated_at:   now
          }
        end

        node_state_model.unscoped.upsert_all(
          payload,
          unique_by: NODE_STATE_UNIQUE_BY
        )

        count += chunk.size
      end

      count
    end

    def parse_table_lines(raw)
      lines = raw.split("\n").map!(&:rstrip)
      start_idx = lines.index { |l| l.strip.start_with?("PARTITION") } || 0
      rows = lines[(start_idx + 1)..] || []
      rows.filter_map { |line| parse_line(line) }
    end

    def parse_line(line)
      m = line.strip.match(/^(\S+)\s+(\S+)\s+(\S+)\s+(\d+)\s+(\S+)\s+(.+)$/)
      return nil unless m

      raw_partition, avail, timelimit, _nodes_count, state_token, nodelist_raw = m.captures
      partition = raw_partition.sub(/\*$/, "")
      state, has_reason = parse_state(state_token)
      hostnames = expand_nodelist(nodelist_raw)

      {
        partition:  partition,
        avail:      avail,
        timelimit:  timelimit,
        state:      state,
        has_reason: has_reason,
        hostnames:  hostnames
      }
    end

    def parse_state(token)
      has_reason = token.end_with?("*")
      base = has_reason ? token[0..-2] : token
      state = STATES.include?(base) ? base : base
      [state, has_reason]
    end

    def expand_nodelist(nodelist_raw)
      str = nodelist_raw.strip
      return str.split(",").map(&:strip).reject(&:empty?) unless str.include?("[")

      result = []
      i = 0

      while i < str.length
        if str[i] == ","
          i += 1
          next
        end

        bracket_pos = str.index("[", i)

        if bracket_pos.nil?
          rest = str[i..]
          rest.split(",").each do |s|
            s = s.strip
            result << s unless s.empty?
          end
          break
        end

        prefix = str[i...bracket_pos]
        close_pos = str.index("]", bracket_pos + 1)
        raise "bad NODELIST: missing ]" unless close_pos

        inner = str[(bracket_pos + 1)...close_pos]
        result.concat(expand_bracket_group(prefix, inner))
        i = close_pos + 1
      end

      result
    end

    def expand_bracket_group(prefix, inner)
      out = []

      inner.split(",").map(&:strip).reject(&:empty?).each do |part|
        if part.include?("-")
          a, b = part.split("-", 2).map!(&:strip)
          width = (a =~ /^\d+$/) ? a.length : nil

          (a.to_i..b.to_i).each do |x|
            num = width ? x.to_s.rjust(width, "0") : x.to_s
            out << "#{prefix}#{num}"
          end
        else
          out << "#{prefix}#{part}"
        end
      end

      out
    end

    def split_prefix_number(hostname)
      m = hostname.match(/^([^\d]*)(\d+)?$/)
      return [hostname, nil] unless m

      prefix = m[1] || ""
      number = m[2] ? m[2].to_i : nil
      [prefix, number]
    end
  end
end