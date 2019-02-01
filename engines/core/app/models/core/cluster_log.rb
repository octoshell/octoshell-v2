# == Schema Information
#
# Table name: core_cluster_logs
#
#  id         :integer          not null, primary key
#  cluster_id :integer          not null
#  message    :text             not null
#  created_at :datetime
#  updated_at :datetime
#  project_id :integer
#

module Core
  class ClusterLog < ActiveRecord::Base
    paginates_per 51
    belongs_to :cluster, inverse_of: :logs
    belongs_to :project, inverse_of: :synchronization_logs
  end
end
