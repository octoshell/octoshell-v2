module Pack
  class Access < ActiveRecord::Base
  	enum status: [:request,:allowed,:denied]
  	validates :version_id, :user_id,presence: true
  	validates_uniqueness_of :user_id, :scope => [:version_id]
  	belongs_to :version
  	belongs_to :user
  	belongs_to :who, :polymorphic => true

  	


  end
end
