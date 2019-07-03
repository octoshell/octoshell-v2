# == Schema Information
#
# Table name: api_exports
#
#  id         :integer          not null, primary key
#  title      :string
#  request    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  text       :text
#

module Api
  class Export < ActiveRecord::Base
    has_and_belongs_to_many :access_keys
		has_and_belongs_to_many :key_parameters
  end
end
