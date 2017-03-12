module Pack

  
  class Version < ActiveRecord::Base
  	
   
    include AASM
    attr_reader :user_access_status,:proj_accesses
  	validates :name, :description,:package, presence: true
    validates_uniqueness_of :name,:scope => :package_id
  	belongs_to :package,inverse_of: :versions
  	has_many :clustervers,:dependent => :destroy
    has_many :version_options,:dependent => :destroy
  	has_many :accesses,:dependent => :destroy
    accepts_nested_attributes_for :version_options,:clustervers, allow_destroy: true
    accepts_my_nested_attributes_for :version_options
    validates_associated :version_options,:clustervers
    scope :finder, ->(q) { where("lower(name) like lower(:q)", q: "%#{q.mb_chars}%").limit(10) }
    validate :date_and_state

    aasm :column => :state  do
     
      state :forever,:available,:expired
      event :to_expired do
        transitions :from =>  :available, :to => :expired
      end
     
    end

    def date_and_state
      
      if state!= "forever" && !end_lic
       
        self.errors.add(:end_lic,:blank)
      end
    end


    
    

    
    def state_select
      
       state == "forever" ? "forever" :  "not_forever"
    end



    
    

    def end_lic_edit(date,state)
      
      self[:end_lic]= if date!="" && state!="forever"
        date= 
         Date.strptime date,Date::DATE_FORMATS[:default]
      else
        ""
      end
      
      date
    end 
    def edit_state_and_lic(state,date)
      
      self.end_lic_edit(date,state) 

       case state
       when "forever"
        self.state="forever"
       when "not_forever"
          
        if !self.end_lic
          self.state = "available"
          return false
        end
          
          
          
        
        
        if  end_lic   >= Date.current 
          self[:state] = "available"
        else 
          self[:state] = "expired"
        end
      else
        raise "incorrect state argument"
       
       end
    end

        
         
    
    def clusters_with_status
      
        
        clustervers= self.clustervers.map do |item|
          
          item.slice("id","core_cluster_id","active","_destroy")

        end
        #checked: s.respond_to?(:active) && !s.active && !s._destroy
        ::Core::Cluster.all.select('id as cluster_id,name').map do |cluster|

          
          clver=  clustervers.detect {|vers| vers[:core_cluster_id] ==cluster.cluster_id }
            
          item=if clver

            OpenStruct.new cluster.attributes.merge(clver)
          else
            OpenStruct.new cluster.attributes
          end
          item.action = if !item.respond_to?(:active) || item._destroy
            "_destroy"
          elsif !item.active 
            "not_active"
          elsif item.active 
            "active"
          
          else 
            raise "incorrect argument"
          end
          item


          
        end
            
    end
    def vers_update params
      params= params.require(:version)
      (hash=params.delete(:version_options_attributes)) && self.version_options_attributes= hash
       update_clustervers params.delete(:my_clustervers)
       
      edit_state_and_lic( params.delete(:state_select),params.delete(:end_lic) ) 
      update(version_params params)

    end
    def update_clustervers hash
      if !hash 
        return 
      end
      hash.each_value do |h|
        method_name=h.delete(:action)
        
        case method_name
        when "active"
          h[:active]="1"
        when "not_active"
          h[:active]="0"
        when "_destroy" 
          h[:_destroy]="1"
        else 
          raise "error"
        end
      end
      
      self.clustervers_attributes= hash
    end


    def self.preload_and_to_a user_id,versions

            
       accesses= Access.select('pack_accesses.*,core_projects.title')
      .joins(
        <<-eoruby
        LEFT JOIN "core_members" ON ( "pack_accesses"."who_id" = "core_members"."project_id" 
        AND "core_members"."user_id" = #{user_id}  )
        LEFT JOIN core_projects ON core_projects.id= core_members.project_id 
        WHERE
        (  "pack_accesses"."who_type" = 'Core::Project'  OR "pack_accesses"."who_type" = 'User'
         AND "pack_accesses"."who_id" = #{user_id}  ) AND "pack_accesses"."version_id" IN (#{(versions.ids).join (',')} )
        eoruby
      )
      
      versions.each do |vers|
        vers.instance_eval  do
          @user_access_status= if v=accesses.detect{|ac| ac.version_id==vers.id && ac.who_type=="User" }   
          v.status       
          else 
            I18n.t("not available")
          end
            @proj_accesses=accesses.select{|ac| ac.version_id==vers.id && ac.who_type=="Core::Project" }
          
        end
      end
      

    end    
    def as_json(options)
    { id: id, text: (name + self.package_id) }
    end
    def version_params params
      params.permit(:name, :description,:version,:folder,:cost)
    end
   
  end
end
