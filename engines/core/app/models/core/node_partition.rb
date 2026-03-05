# == Schema Information
#
# Table name: core_node_partitions
#
#  id           :integer          not null, primary key
#  node_id      :integer          not null
#  partition_id :integer          not null
#  created_at   :datetime
#  updated_at   :datetime
#
# Indexes
#
#  index_core_node_partitions_on_node_id_and_partition_id  (node_id,partition_id) UNIQUE
#

module Core
  class NodePartition < ApplicationRecord
    belongs_to :node, class_name: 'Core::Node'
    belongs_to :partition, class_name: 'Core::Partition'
  end
end
