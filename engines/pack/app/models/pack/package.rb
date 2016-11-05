module Pack
  class Package < ActiveRecord::Base
  	validates :name, :folder, :cost, presence: true
  	validates :name,uniqueness: true 
  end
end
