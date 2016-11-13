module Pack
  class Package < ActiveRecord::Base
  	validates :name, :folder, :cost,:description, presence: true
  	validates :name,uniqueness: true 
  	has_many :versions,:dependent => :destroy
  end
end
