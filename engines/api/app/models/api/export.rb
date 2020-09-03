# == Schema Information
#
# Table name: api_exports
#
#  id         :integer          not null, primary key
#  request    :text
#  safe       :boolean          default(TRUE)
#  text       :text
#  title      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

module Api
  class Export < ActiveRecord::Base
  	validates :title, uniqueness: true, allow_blank: false, allow_nil: false
  	
    has_and_belongs_to_many :access_keys
		has_and_belongs_to_many :key_parameters
  end
end
