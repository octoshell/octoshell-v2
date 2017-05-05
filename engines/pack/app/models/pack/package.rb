module Pack
  class Package < ActiveRecord::Base
    
  	self.locking_column = :lock_version
  	validates :name, :description, presence: true
  	validates :name,uniqueness: true 
  	has_many :versions,:dependent => :destroy,inverse_of: :package
  	scope :finder, ->(q) { where("lower(name) like lower(:q)", q: "%#{q.mb_chars}%") }
    #scope :, -> { where(published: true) }
  	def as_json(options)
    { id: id, text: name }
  	end
    def self.ransackable_scopes(auth_object = nil)
      [:user_access]
    end
    def self.allowed_for_users user_id


      all.merge(Version.allowed_for_users user_id)
    end
    def self.user_access user_id
      
      if user_id==true
        user_id=1
      end
      joins(versions: :accesses).merge(Access.inner_join_user_access user_id)
    end
  end
  
end
