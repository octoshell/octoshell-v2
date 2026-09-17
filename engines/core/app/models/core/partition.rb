# == Schema Information
#
# Table name: core_partitions
#
#  cluster_id :integer
#  default    :boolean          default(FALSE), not null
#  id         :integer          not null, primary key
#  name       :string
#  resources  :string
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
