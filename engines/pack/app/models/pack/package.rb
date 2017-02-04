module Pack
  class Package < ActiveRecord::Base
  	validates :name, :folder, presence: true
  	validates :name,uniqueness: true 
  	has_many :versions,:dependent => :destroy
  	scope :finder, ->(q) { where("lower(name) like lower(:q)", q: "%#{q.mb_chars}%") }
  	def as_json(options)
    { id: id, text: name }
  	end
  end
  
end
