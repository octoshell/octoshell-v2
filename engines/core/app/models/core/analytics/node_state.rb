module Core
  module Analytics
    class NodeState < ApplicationRecord
      self.table_name = 'core_analytics_node_states'

      STATES    = %w[alloc idle comp drain drng down maint reserved mix].freeze
      SUBSTATES = %w[unknown maintenance pending draining].freeze

      def system
        cluster
      end

      def system=(v)
        self.cluster = v
      end

      belongs_to :cluster, class_name: 'Core::Cluster'
      belongs_to :partition, class_name: 'Core::Partition'
      belongs_to :node, class_name: 'Core::Analytics::Node'
      belongs_to :snapshot, class_name: 'Core::Analytics::Snapshot'


      validates :state, presence: true, inclusion: { in: STATES }
      validates :substate, allow_nil: true, inclusion: { in: SUBSTATES }
      validates :has_reason, inclusion: { in: [true, false] }
      validates :valid_from, presence: true

      scope :current, -> { where(valid_to: nil) }
      scope :at, ->(ts) { where("valid_from <= ? AND (valid_to IS NULL OR valid_to > ?)", ts, ts) }
    end
  end
end
