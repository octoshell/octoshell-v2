# == Schema Information
#
# Table name: core_access_fields
#
#  id            :integer          not null, primary key
#  quota         :integer
#  used          :integer          default(0)
#  access_id     :integer
#  quota_kind_id :integer
#
# Indexes
#
#  index_core_access_fields_on_access_id  (access_id)
#

module Core
  class AccessField < ActiveRecord::Base

    has_paper_trail

    belongs_to :access
    belongs_to :quota_kind

    def to_s
      "#{quota_kind.name}: #{quota} #{quota_kind.measurement}"
    end
  end
end
