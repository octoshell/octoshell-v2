# == Schema Information
#
# Table name: api_access_keys
#
#  id         :integer          not null, primary key
#  key        :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

module Api
  class AccessKey < ActiveRecord::Base
    has_and_belongs_to_many :exports
    accepts_nested_attributes_for :exports
  end
end
