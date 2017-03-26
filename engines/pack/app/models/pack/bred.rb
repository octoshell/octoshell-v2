module Pack

  
  class Bred < ActiveRecord::Base
  	
  	validates :name, :description,:package, presence: true
    validates_format_of :end_lic, :with => /(\A\d{2}.\d{2}.\d{4}\Z)|(\A\Z)/ , :allow_nil => true
    validates_uniqueness_of :name,:scope => :package_id
  	belongs_to :package,inverse_of: :versions
  	has_many :clustervers,:dependent => :destroy
    has_many :version_options,:dependent => :destroy
  	has_many :accesses,:dependent => :destroy
    accepts_nested_attributes_for :version_options,:clustervers, allow_destroy: true
    accepts_my_nested_attributes_for :version_options
    validates_associated :version_options,:clustervers
    #yard
    ##makedoc
  	#has_many :user_accesses,-> { where(  "who_type= 'User' AND who_id in (?)",Version.user_id) }, class_name: "Access"
  	#has_many :proj_accesses,-> { where(  "who_type= 'Core::Project' AND who_id in (?) ",Version.proj_ids) }, class_name: "Access"
    #has_many :proj_accesses_allowed,-> { where(  "who_type= 'Core::Project' AND who_id in (?) And status=(?) ",Version.proj_ids,Access.statuses[:allowed]) }, class_name: "Access"
    scope :finder, ->(q) { where("lower(name) like lower(:q)", q: "%#{q.mb_chars}%").limit(10) }

    def self.many_and_preload(user_id)
      ids= Core::Project.joins(members: :user).where(users: {id: user_id}).pluck('core_projects.id')
      has_many :user_accesses,-> { where(  "who_type= 'User' AND who_id in (?)",user_id) }, class_name: "Access"
      has_many :proj_accesses,-> { where(  "who_type= 'Core::Project' AND who_id in (?) ",ids) }, class_name: "Access"
      has_many :proj_accesses_allowed,-> { where(  "who_type= 'Core::Project' AND who_id in (?) And status=(?) ",ids,Access.statuses[:allowed]) }, class_name: "Access"
      includes({clustervers: :core_cluster},:user_accesses,{proj_accesses_allowed: :who},{proj_accesses: :who})
 
    end    
    def as_json(options)
    { id: id, text: (name + self.package_id) }
    end

   
  end
end
