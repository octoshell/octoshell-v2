module Pack
  class Package < ActiveRecord::Base
    
  	self.locking_column = :lock_version
  	validates :name, :description, presence: true
  	validates :name,uniqueness: true 
  	has_many :versions,:dependent => :destroy,inverse_of: :package
  	scope :finder, ->(q) { where("lower(name) like lower(:q)", q: "%#{q.mb_chars}%") }
  	def as_json(options)
    { id: id, text: name }
  	end
    

    before_save do 
      if deleted==true
        versions.load
       versions.each do |v|
          v.deleted=true
          v.save
        end
      end
    end
    def self.allowed_for_users


      all.merge(Version.allowed_for_users)
    end
    def self.user_access user_id
      
      if user_id==true
        user_id=1
      end
      joins(:versions).merge(Version.user_access user_id)
    end
  end
  
end
