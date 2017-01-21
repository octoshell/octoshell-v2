module Pack
  class Clusterver < ActiveRecord::Base
  	validates :core_cluster_id, :version_id, presence: true
  	belongs_to :core_cluster,class_name: "Core::Cluster"
  	belongs_to :version
  end
end
