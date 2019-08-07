# == Schema Information
#
# Table name: core_cluster_quotas
#
#  id            :integer          not null, primary key
#  value         :integer
#  cluster_id    :integer          not null
#  quota_kind_id :integer
#
# Indexes
#
#  index_core_cluster_quotas_on_cluster_id  (cluster_id)
#

module Core
  class ClusterQuota < ApplicationRecord
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
