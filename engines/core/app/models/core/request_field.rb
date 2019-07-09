# == Schema Information
#
# Table name: core_request_fields
#
#  id            :integer          not null, primary key
#  value         :integer
#  quota_kind_id :integer
#  request_id    :integer          not null
#
# Indexes
#
#  index_core_request_fields_on_request_id  (request_id)
#

module Core
  class RequestField < ActiveRecord::Base

    has_paper_trail

    belongs_to :request
    belongs_to :quota_kind

    validates :request, :value, presence: true

    def to_s
      "#{quota_kind.name}: #{value} #{quota_kind.measurement}"
    end
  end
end
