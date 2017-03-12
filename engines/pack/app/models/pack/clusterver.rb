module Pack
  class Clusterver < ActiveRecord::Base
  	validates :core_cluster, presence: true
  	validates_uniqueness_of :version_id,:scope => :core_cluster_id
  	belongs_to :core_cluster,class_name: "Core::Cluster"
  	belongs_to :version
  end
end
