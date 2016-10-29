module Core
  class ClusterLog < ActiveRecord::Base
    paginates_per 51
    belongs_to :cluster, inverse_of: :logs
    belongs_to :project, inverse_of: :synchronization_logs
  end
end
