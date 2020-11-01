Core::Cluster.class_eval do
	has_many :clustervers, class_name: "Pack::Clusterver" ,inverse_of: :core_cluster,foreign_key: :core_cluster_id,dependent: :destroy
end
# Support::Ticket.class_eval do
# 	has_and_belongs_to_many :pack_accesses,
#                           join_table: 'pack_access_tickets',
#                           class_name: "Pack::Access",
#                           foreign_key: "ticket_id",
#                           association_foreign_key: "access_id"
# end
