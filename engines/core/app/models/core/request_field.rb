# == Schema Information
#
# Table name: core_request_fields
#
#  id            :integer          not null, primary key
#  request_id    :integer          not null
#  value         :integer
#  quota_kind_id :integer
#

module Core
  class RequestField < ActiveRecord::Base
    belongs_to :request
    belongs_to :quota_kind

    validates :request, :value, presence: true

    def to_s
      "#{quota_kind.name}: #{value} #{quota_kind.measurement}"
    end
  end
end
