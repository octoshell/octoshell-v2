module Pack

  
  class Version < ActiveRecord::Base
  	class <<self
		attr_accessor :type
		attr_accessor :id
  	end
  	validates :name, :description, presence: true
  	belongs_to :package
  	has_many :clustervers,:dependent => :destroy
  	has_many :accesses,:dependent => :destroy
  	has_many :user_accesses,-> { where(  "who_type= ? AND who_id=?",Version.type,Version.id) }, class_name: "Access"

  end
end
