module Core
  module Analytics
    class Node < ApplicationRecord
      self.table_name = 'core_analytics_nodes'

      belongs_to :cluster, class_name: 'Core::Cluster'

      def system
        cluster
      end

      def system=(v)
        self.cluster = v
      end

      has_many :node_states,
               class_name: 'Core::Analytics::NodeState',
               foreign_key: :node_id,
               dependent: :destroy

      has_many :partitions,
               -> { distinct },
               through: :node_states,
               source: :partition

      validates :hostname, presence: true, uniqueness: { scope: :cluster_id }
      validates :prefix, presence: true
    end
  end
end