# == Schema Information
#
# Table name: core_cluster_quotas
#
#  id            :integer          not null, primary key
#  cluster_id    :integer          not null
#  value         :integer
#  quota_kind_id :integer
#

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
