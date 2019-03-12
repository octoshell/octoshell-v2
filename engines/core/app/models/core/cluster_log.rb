# == Schema Information
#
# Table name: core_cluster_logs
#
#  id         :integer          not null, primary key
#  message    :text             not null
#  created_at :datetime
#  updated_at :datetime
#  cluster_id :integer          not null
#  project_id :integer
#
# Indexes
#
#  index_core_cluster_logs_on_cluster_id  (cluster_id)
#  index_core_cluster_logs_on_project_id  (project_id)
#

module Core
  class ClusterLog < ActiveRecord::Base
    paginates_per 51
    belongs_to :cluster, inverse_of: :logs
    belongs_to :project, inverse_of: :synchronization_logs
  end
end
