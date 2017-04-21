module Pack
  class Access < ActiveRecord::Base
  	#enum status: [:requested,:allowed,:denied]
  	#@a=[t("Create request"),t("new date")]
    include AASM
    american_date_proccess

    scope :preload_who, -> { select("pack_accesses.*,u.email as who_user,proj.title as who_project,g.name as who_group").joins(<<-eoruby
        
         LEFT JOIN core_projects as proj ON (proj.id= "pack_accesses"."who_id" AND pack_accesses.who_type='Core::Project'  )
         LEFT JOIN users as u ON (u.id= "pack_accesses"."who_id" AND pack_accesses.who_type='User'  )
         LEFT JOIN groups as g ON (g.id= "pack_accesses"."who_id" AND pack_accesses.who_type='Group'  )
       
        eoruby
        ) 
        }

    def self.admin_user_access(user_id)

      user_access(user_id).joins(<<-eoruby
        JOIN users ON (users.id= pack_accesses.who_id AND pack_accesses.who_type='User'
        OR pack_accesses.who_type='Core::Project' AND "core_members"."user_id" = #{user_id} 
        OR pack_accesses.who_type='Group' AND "user_groups"."user_id" = #{user_id}   )
        eoruby
        )
      
    end

    def self.user_access(user_id)


        select('pack_accesses.*,core_projects.title as who_project,groups.name as who_group').user_access_without_select user_id
    end


    def self.user_access_without_select(user_id)


        joins(
        <<-eoruby
        LEFT JOIN "core_members" ON ( "pack_accesses"."who_id" = "core_members"."project_id" 
        AND "core_members"."user_id" = #{user_id} AND "pack_accesses"."who_type" = 'Core::Project'   )
        LEFT JOIN core_projects ON core_projects.id= core_members.project_id 
        eoruby
        ).joins(
        <<-eoruby
        LEFT JOIN "user_groups" ON ( "pack_accesses"."who_id" = "user_groups"."group_id" 
        AND "user_groups"."user_id" = #{user_id}   AND "pack_accesses"."who_type" = 'Group' )
        LEFT JOIN "groups" ON ( "user_groups"."group_id" = "groups"."id"  )
        eoruby
        ).where(
        <<-eoruby
        (  "pack_accesses"."who_type" = 'Core::Project' OR "pack_accesses"."who_type" = 'Group'  OR "pack_accesses"."who_type" = 'User'
         AND "pack_accesses"."who_id" = #{user_id}  ) 
         eoruby
         )
    end
    
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
     
    end
    def self.states_list
      
      aasm.states.map(&:to_s)
      
    end
    def self.ransackable_scopes(auth_object = nil)
      [:user_access,:admin_user_access]
    end

    #private_class_method :ransackable_scopes
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

    


  	validates :version, :created_by_key,:who,:status,presence: true
    validates_uniqueness_of :who_id,:scope => [:version_id,:who_type],:message => :uniq_access
    validate :date_and_status,:date_correct,:new_end_lic_correct

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

    def get_color
      case status
      when 'allowed'
        'green'
      when 'requested'
        'blue'
      when 'denied'
        'red'
      when 'expired'
        'yellow'
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

    def new_end_lic_correct
      
      if end_lic && new_end_lic && end_lic > new_end_lic
        self.errors.add(:new_end_lic,:incorect)
      end
    end

    def end_lic_readable
      end_lic || Access.human_attribute_name(:forever)
    end


  	belongs_to :version
  	belongs_to :created_by,class_name: 'User',foreign_key: :created_by_key
  	belongs_to :who, :polymorphic => true
    
  	
   

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

    
    def who_name_with_type
      
      
      
      "#{I18n.t('who_types.'+who_type)} #{who_name}"
        #!who_user.nil? && who_user ||  !who_group.nil? && who_group || !who_project.nil? && who_project 
    end
    

    def who_name
      who_group || who_project || who_user 
    end

  	


  end
end
