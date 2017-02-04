module Pack
  class Access < ActiveRecord::Base
  	enum status: [:requested,:allowed,:denied]
  	#@a=[t("Create request"),t("new date")]
  	validates :version_id, :user_id,:who_id,:who_type,:status,presence: true
    validates_uniqueness_of :version_id,:scope => [:who_id,:who_type],:message => :uniq_access
  	belongs_to :version
  	belongs_to :user
  	belongs_to :who, :polymorphic => true
  	

  	


  end
end
