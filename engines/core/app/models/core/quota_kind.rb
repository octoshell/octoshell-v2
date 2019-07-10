# == Schema Information
#
# Table name: core_quota_kinds
#
#  id             :integer          not null, primary key
#  name_ru        :string(255)
#  measurement_ru :string(255)
#  name_en        :string
#  measurement_en :string
#

module Core
  class QuotaKind < ApplicationRecord

    has_paper_trail

    translates :name, :measurement

    validates_translated :name, :measurement, presence: true
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
