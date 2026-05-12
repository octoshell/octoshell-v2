# module Core
#   module Analytics
#     class System < ApplicationRecord
#       self.table_name = 'core_analytics_systems'
#       has_many :nodes,       class_name: 'Core::Analytics::Node',       foreign_key: :system_id, dependent: :destroy
#       has_many :partitions,  class_name: 'Core::Analytics::Partition',  foreign_key: :system_id, dependent: :destroy
#       has_many :snapshots,   class_name: 'Core::Analytics::Snapshot',   foreign_key: :system_id, dependent: :destroy
#       has_many :node_states, class_name: 'Core::Analytics::NodeState',  foreign_key: :system_id, dependent: :destroy

#       validates :name, :slug, presence: true
#       validates :name, :slug, uniqueness: true
#     end
#   end
# end

module Core
  module Analytics
    System = ::Core::Cluster
  end
end

