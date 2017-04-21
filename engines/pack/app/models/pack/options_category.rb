module Pack
  class OptionsCategory < ActiveRecord::Base
  	validates :category,presence: true,uniqueness: true
  end

end
