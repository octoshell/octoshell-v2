# == Schema Information
#
# Table name: core_partitions
#
#  id         :integer          not null, primary key
#  name       :string
#  resources  :string
#  cluster_id :integer
#
# Indexes
#
#  index_core_partitions_on_cluster_id  (cluster_id)
#

module Core
  class Partition < ApplicationRecord
    belongs_to :cluster
    has_many :node_partitions, class_name: 'Core::NodePartition', dependent: :destroy
    has_many :nodes, through: :node_partitions
  end
end
