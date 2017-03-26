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
  end
  
end
