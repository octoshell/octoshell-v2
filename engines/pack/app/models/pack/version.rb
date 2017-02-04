module Pack

  
  class Version < ActiveRecord::Base
  	class <<self
		attr_accessor :user_id
		attr_accessor :proj_ids
  	end
  	validates :name, :description,:package_id, presence: true
  	belongs_to :package
  	has_many :clustervers,:dependent => :destroy
  	has_many :accesses,:dependent => :destroy
  	has_many :user_accesses,-> { where(  "who_type= 'User' AND who_id in (?)",Version.user_id) }, class_name: "Access"
  	has_many :proj_accesses,-> { where(  "who_type= 'Core::Project' AND who_id in (?) ",Version.proj_ids) }, class_name: "Access"
    has_many :proj_accesses_allowed,-> { where(  "who_type= 'Core::Project' AND who_id in (?) And status=(?) ",Version.proj_ids,Access.statuses[:allowed]) }, class_name: "Access"
    scope :finder, ->(q) { where("lower(name) like lower(:q)", q: "%#{q.mb_chars}%").limit(10) }
    def as_json(options)
    { id: id, text: (name + self.package_id) }
    end
  end
end
