# == Schema Information
#
# Table name: api_key_parameters
#
#  id         :integer          not null, primary key
#  name       :string
#  default    :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

module Api
  class KeyParameter < ActiveRecord::Base
  	validates :name, uniqueness: true, allow_blank: false, allow_nil: false
  	has_and_belongs_to_many :exports
  end
end
