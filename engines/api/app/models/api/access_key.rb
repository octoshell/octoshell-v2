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
  	validates :key, uniqueness: true, allow_blank: false, allow_nil: false
    has_and_belongs_to_many :exports
  end
end
