module Pack
  class Access < ActiveRecord::Base
  	#enum status: [:requested,:allowed,:denied]
  	#@a=[t("Create request"),t("new date")]
    include AASM
    american_date_proccess
    
    def forever=(arg)
      @forever= arg=='false' ? false : true 
    end
    def forever
      @forever || false 
    end

    def expected_status
      status
    end

    def actions
      if status == 'allowed' && new_end_lic
        aasm.states(:permitted => true).map(&:to_s)<<'make_longer'
      else
        aasm.states(:permitted => true).map(&:to_s)
      end
      
      #aasm.states(:permitted => true)

    end
    def action= arg
      if ! ( actions.detect{ |i| i==arg  } ) 
        raise 'incorect argument'
      end
      if arg == 'make_longer'

        if !new_end_lic ||( end_lic >= new_end_lic )

          raise 'incorect new_end_lic'

        end

        self.end_lic= new_end_lic
        self.new_end_lic= nil


      else
        self.status= arg
      end       
    end

    


  	validates :version_id, :created_by_key,:who,:status,presence: true
    validates_uniqueness_of :who_id,:scope => [:version_id,:who_type],:message => :uniq_access
    validate :date_and_status,:date_correct

    aasm :column => :status  do
     
      state :requested,:initial => true
      state :allowed
      state :denied
      state :expired
      event :to_expired do
        transitions :from =>  :allowed, :to => :expired,:guard => :check_expired? 
      end
      event :allow do
        transitions :from =>  :requested, :to => :allowed
      end

      event :deny do
        transitions :from =>  [:requested,:allowed], :to => :denied
      end
     
    end

    def check_expired?
      end_lic && ( end_lic < Date.current )
    end
    def date_correct
      
      if new_end_lic && !end_lic 
        self.errors.add(:new_end_lic,'must be blank')
      end
    end


    def date_and_status
      
      if !forever && !end_lic
        self.errors.add(:end_lic,:blank)
      end
    end

    def end_lic_readable
      end_lic || I18n.t('forever')
    end


  	belongs_to :version
  	belongs_to :created_by,class_name: 'User',foreign_key: :created_by_key
  	belongs_to :who, :polymorphic => true
    belongs_to :who_project, foreign_key: :who_id,class_name: 'Core::Project'
    belongs_to :who_user, foreign_key: :who_id,class_name: 'User'
  	
   

    def self.execute_find_query params,user_id

      
            

    end
    def self.search_access ( params,user_id )

      #update_params=params.clone
     
      find_params=  case params[:proj_or_user]
          when 'user'
            { who_id: user_id,who_type: 'User' }    
          else
             { who_id: params[:proj_or_user] ,who_type: 'Core::Project' }       
          end
      find_params.merge! params.slice(:version_id) 
      params.slice!(:end_lic,:new_end_lic)
      params.merge! find_params
      params.permit!
      Access.find_by(find_params)   ||       
      #execute_find_query(update_params,user_id)
     Access.new(params)

      
     

    end
    def self.user_update( access_params,user_id )

     
      puts user_id
      access=Access.find_by(access_params.slice(:who_id,:who_type,:version_id))   ||       
      #execute_find_query(update_params,user_id)
     Access.new(access_params.slice(:who_id,:who_type,:version_id,:end_lic,:new_end_lic,:forever))
    
      
      
      
      if access.new_record?
        raise "ERROR in new" if access_params[:expected_status]!="new"
        access.created_by_key = user_id
        
      else
        raise "ERROR in existing" if access_params[:expected_status]!=access.status
        access.attributes= access_params.slice(:new_end_lic)
        
      
      end

     access 
     
     
     
    end
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
