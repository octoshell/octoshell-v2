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
  class Partition < ActiveRecord::Base
    belongs_to :cluster
  end
end
