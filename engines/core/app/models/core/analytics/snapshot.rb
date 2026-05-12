module Core
  module Analytics
    class Snapshot < ApplicationRecord
      self.table_name = 'core_analytics_snapshots'
      
      belongs_to :cluster, class_name: 'Core::Cluster'


      def system
        cluster
      end

      def system=(v)
        self.cluster = v
      end

      has_many :node_states, class_name: 'Core::Analytics::NodeState', foreign_key: :snapshot_id, dependent: :destroy
      
      scope :latest_first, -> { order(captured_at: :desc) }
      validates :captured_at, :source_cmd, :parser_version, :raw_text, presence: true
    end
  end
end
