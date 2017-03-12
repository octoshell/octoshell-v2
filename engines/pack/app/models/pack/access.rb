module Pack
  class Access < ActiveRecord::Base
  	#enum status: [:requested,:allowed,:denied]
  	#@a=[t("Create request"),t("new date")]
  	validates :version_id, :user_id,:who_id,:who_type,:status,presence: true
    validates_uniqueness_of :who_id,:scope => [:version_id,:who_type],:message => :uniq_access
    

  	belongs_to :version
  	belongs_to :user
  	belongs_to :who, :polymorphic => true
    belongs_to :who_project, foreign_key: :who_id,class_name: 'Core::Project'
    belongs_to :who_user, foreign_key: :who_id,class_name: 'User'
  	
    def who_name
      
      
      
      
      




      case who_type 
        when 'User'
          "#{I18n.t ('user')} #{who_user.email}"
        when 'Core::Project'
          "#{I18n.t ('project')} #{who_project.title}"
        else
          raise ActiveRecord::RecordInvalid
        end
    end

  	


  end
end
