# == Schema Information
#
# Table name: core_clusters
#
#  id                 :integer          not null, primary key
#  admin_login        :string(255)
#  available_for_work :boolean          default(TRUE)
#  description        :text
#  host               :string(255)      not null
#  name_en            :string
#  name_ru            :string(255)      not null
#  private_key        :text
#  public_key         :text
#  created_at         :datetime
#  updated_at         :datetime
#
# Indexes
#
#  index_core_clusters_on_private_key  (private_key) UNIQUE
#  index_core_clusters_on_public_key   (public_key) UNIQUE
#

module Core
  class Cluster < ApplicationRecord
    translates :name

    has_many :requests, inverse_of: :cluster, dependent: :destroy
    has_many :accesses, inverse_of: :cluster, dependent: :destroy
    has_many :projects, through: :accesses

    has_many :partitions, inverse_of: :cluster, dependent: :destroy
    has_many :nodes, class_name: 'Core::Node', inverse_of: :cluster, dependent: :destroy
    accepts_nested_attributes_for :partitions, allow_destroy: true

    has_many :logs, class_name: 'ClusterLog', inverse_of: :cluster, dependent: :destroy

    has_many :quotas, class_name: 'ClusterQuota', inverse_of: :cluster, dependent: :destroy
    accepts_nested_attributes_for :quotas, allow_destroy: true
    validates :host, :admin_login, presence: true
    validates_translated :name, presence: true
    scope :finder, lambda { |q|
      where("lower(#{current_locale_column(:name)}) like :q", q: "%#{q.mb_chars.downcase}%").order current_locale_column(:name)
    }

    before_create do
      generate_ssh_keys
    end

    def log(message, project)
      logs.create!(message: message, project: project)
    end

    def quotas_info
      quotas.map(&:to_s).join(' | ')
    end

    def to_s
      name
    end

    def as_json(_options = nil)
      { id: id, text: name }
    end

    def execute(command, ssh = nil)
      return exec!(ssh, command) if ssh

      Net::SSH.start(host, admin_login, key_data: private_key) do |ssh|
        exec!(ssh, command)
      end
    end

    def exec!(ssh, command)
      stdout_data = ''
      stderr_data = ''
      ssh.exec!(command) do |_channel, stream, data|
        case stream
        when :stdout
          stdout_data << data
        when :stderr
          stderr_data << data
        end
      end
      [stdout_data, stderr_data].map { |d| d.force_encoding('UTF-8') }
    end

    # Logs the state of all cluster nodes via sinfo command
    # sinfo output format: NodeName Partition State Reason
    # Example: node001 batch idle~ None
    #          node002 batch down~ Drain reason here
    # Supports node ranges in format: n[54103,54107-54110,54115-54125]
    # Creates nodes if they don't exist
    # Treats 'allocated' and 'idle' as equivalent states
    # Optimized for performance: uses batch loading and bulk insert
    def log_node_states
      # Actually sinfo -h -o "%N %R %T %E"' happens here
      stdout, stderr = execute('sudo /usr/octo/sinfo_log_nodes')
      raise "Error when retrieving sinfo_log_nodes: #{stderr}" if stderr.present?

      # Parse all lines first
      parsed_lines = stdout.each_line.filter_map do |line|
        parts = line.strip.split(/\s+/, 4)
        next if parts.size < 3

        {
          node_names_raw: parts[0],
          partition_name: parts[1],
          state: parts[2],
          reason: parts[3].presence
        }
      end

      return true if parsed_lines.empty?

      # Collect all unique partition names and node names
      partition_names = parsed_lines.map { |l| l[:partition_name] }.uniq
      all_node_names = parsed_lines.flat_map { |l| expand_node_names(l[:node_names_raw]) }.uniq

      # Load existing partitions in one query
      existing_partitions = partitions.where(name: partition_names).index_by(&:name)

      # Create missing partitions with bulk insert
      new_partition_names = partition_names - existing_partitions.keys
      if new_partition_names.any?
        partitions.insert_all(new_partition_names.map { |name| { name: name } })
        existing_partitions.merge!(partitions.where(name: new_partition_names).index_by(&:name))
      end

      # Load existing nodes in one query
      existing_nodes = nodes.where(name: all_node_names).index_by(&:name)

      # Create missing nodes with bulk insert
      new_node_names = all_node_names - existing_nodes.keys
      if new_node_names.any?
        nodes.insert_all(new_node_names.map { |name| { name: name, cluster_id: id } })
        existing_nodes.merge!(nodes.where(name: new_node_names).index_by(&:name))
      end

      # Get last states for all nodes using SQL (DISTINCT ON for PostgreSQL)
      # This loads only the latest state per node, not all states
      node_ids = existing_nodes.values.map(&:id)
      last_states_hash = if node_ids.any?
                           # Use DISTINCT ON to get only the latest state for each node
                           # This is memory-efficient as it doesn't load all historical states
                           sql = <<-SQL.squish
                             SELECT DISTINCT ON (node_id) id, node_id, state, reason, state_time
                             FROM core_node_states
                             WHERE node_id IN (#{node_ids.join(',')})
                             ORDER BY node_id, state_time DESC
                           SQL
                           Core::NodeState.find_by_sql(sql).index_by(&:node_id)
                         else
                           {}
                         end

      # Prepare data for bulk insert
      node_partition_data = []
      node_states_data = []

      parsed_lines.each do |line|
        partition = existing_partitions[line[:partition_name]]
        normalized_state = Core::Node.normalize_state(line[:state])

        expand_node_names(line[:node_names_raw]).each do |node_name|
          node = existing_nodes[node_name]
          node_partition_data << { node_id: node.id, partition_id: partition.id }

          # Check if state changed using cached data
          last_state = last_states_hash[node.id]
          last_normalized = last_state ? Core::Node.normalize_state(last_state.state) : nil

          next unless last_normalized != normalized_state || last_state&.reason != line[:reason]

          node_states_data << { node_id: node.id, state: line[:state], reason: line[:reason], state_time: Time.current }
        end
      end

      # Insert node-partition associations using bulk insert, ignoring duplicates
      Core::NodePartition.insert_all(node_partition_data.uniq, unique_by: %i[node_id partition_id])

      # Bulk insert node states
      Core::NodeState.insert_all(node_states_data) if node_states_data.any?

      true
    end

    private

    def generate_ssh_keys
      key = SSHKey.generate(comment: host)
      self.public_key = key.ssh_public_key
      self.private_key = key.private_key
    end

    # Expands node name ranges like n[54103,54107-54110,54115-54125] into individual node names
    # @param node_names_raw [String] raw node names from sinfo
    # @return [Array<String>] list of individual node names
    def expand_node_names(node_names_raw)
      result = []

      # Match patterns like n[54103,54107-54110,54115-54125]
      if node_names_raw =~ /^([^\[\]]+)\[([^\[\]]+)\]$/
        prefix = Regexp.last_match[1]
        ranges_str = Regexp.last_match[2]

        # Parse each range or single number
        ranges_str.split(',').each do |part|
          part = part.strip
          if part.include?('-')
            # It's a range like 54107-54110
            start_num, end_num = part.split('-').map(&:to_i)
            (start_num..end_num).each do |num|
              result << "#{prefix}#{num}"
            end
          else
            # It's a single number
            result << "#{prefix}#{part}"
          end
        end
      else
        # No range, just a single node name
        result << node_names_raw
      end

      result
    end
  end
end
