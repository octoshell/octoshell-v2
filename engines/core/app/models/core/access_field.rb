# == Schema Information
#
# Table name: core_access_fields
#
#  id            :integer          not null, primary key
#  access_id     :integer
#  quota         :integer
#  used          :integer          default(0)
#  quota_kind_id :integer
#

module Core
  class AccessField < ActiveRecord::Base
    belongs_to :access
    belongs_to :quota_kind

    def to_s
      "#{quota_kind.name}: #{quota} #{quota_kind.measurement}"
    end
  end
end
