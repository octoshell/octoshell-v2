module Core
  class ClusterQuota < ActiveRecord::Base
    # Since rails doesn't recognises, that qouta in plural will be qoutas,
    # we have to manually define table name here.
    self.table_name = "core_cluster_quotas"

    belongs_to :cluster
    belongs_to :quota_kind

    def to_s
      "#{quota_kind.name}: #{value} #{quota_kind.measurement}"
    end
  end
end
