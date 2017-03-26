module Pack
  class Clusterver < ActiveRecord::Base
  	delegate :name,to: :core_cluster
  	validates :core_cluster,:version, presence: true
  	validates_uniqueness_of :version_id,:scope => :core_cluster_id
  	belongs_to :core_cluster,class_name: "Core::Cluster",inverse_of: :clustervers
  	belongs_to :version,inverse_of: :clustervers
  	def action
  		return "_destroy" if marked_for_destruction?
  		if active 
  		 	"active"
  		else 
  			"not_active"
  		end
  	end
  end
end
