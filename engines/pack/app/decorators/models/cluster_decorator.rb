Core::Cluster.class_eval do 
	has_many :clustervers,class_name: "Pack::Clusterver" ,inverse_of: :core_cluster,foreign_key: :core_cluster_id
end 
