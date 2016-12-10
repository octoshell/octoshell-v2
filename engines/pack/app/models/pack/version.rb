module Pack
  class Version < ActiveRecord::Base
  	validates :name, :description, presence: true
  	belongs_to :package
  	has_many :clustervers,:dependent => :destroy
  	has_many :uservers,:dependent => :destroy
  	has_many :projectsvers,:dependent => :destroy
  end
end
