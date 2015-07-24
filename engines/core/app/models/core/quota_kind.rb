module Core
  class QuotaKind < ActiveRecord::Base
    validates :name, :measurement, presence: true
    has_many :cluster_quotas, class_name: "ClusterQuota", inverse_of: :quota_kind, dependent: :destroy
    has_many :request_fields, dependent: :destroy
    has_many :access_fields, dependent: :destroy

    def full_name
      "#{name}, #{measurement}"
    end

    def to_s
      full_name
    end
  end
end
