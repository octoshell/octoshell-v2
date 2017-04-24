module Pack

  
  class Version < ActiveRecord::Base
  	
     
    include AASM
    american_date_proccess
    attr_accessor :user_accesses

  	validates :name, :description,:package, presence: true
    validates_uniqueness_of :name,:scope => :package_id
  	belongs_to :package,inverse_of: :versions
  	has_many :clustervers,inverse_of: :version, :dependent => :destroy
    has_many :version_options,inverse_of: :version,:dependent => :destroy
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
      
      if state=="forever"
        date=""
      end
      self.end_lic=(date)

       case state
       when "forever"
        self.state="forever"
       when "not_forever"
          
        if !self.end_lic
          self.state = "available"
          return false
        end
        if  self[:end_lic]   >= Date.current 
          self[:state] = "available"
        else 
          self[:state] = "expired"
        end
      else
        raise "incorrect state argument"
       
       end
    end

        
         
    
    
    
    def create_temp_clusterver(cluster_id)
      clustervers.new(core_cluster_id: cluster_id).mark_for_destruction  
    end
    def create_temp_clustervers
      if new_record?
        cl= ::Core::Cluster.all
        cl.each do |t| 
          
            create_temp_clusterver t.id
          
        end
      else
        cl= ::Core::Cluster.select('core_clusters.id ,pack_clustervers.id as ex').uniq.joins("LEFT JOIN pack_clustervers ON  (core_clusters.id = pack_clustervers.core_cluster_id AND pack_clustervers.version_id=#{self.id})")
      
        cl.each do |t| 
          if !t.ex
            create_temp_clusterver t.id
          end
        end
      end
      
    end
     


          
       
    def vers_update params
      
      params= params.require(:version)
      (hash=params.delete(:version_options_attributes)) && self.version_options_attributes= hash
       update_clustervers params.delete(:clustervers_attributes)
       
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
          create_temp_clusterver h[:core_cluster_id]
          h[:_destroy]="1"
        else 
          raise "error"
        end
      end
     
      self.clustervers_attributes= hash
    end

     def self.preload_and_to_a user_id,versions

            
       accesses=Access.user_access(user_id).where(version_id: versions.ids )#where("pack_accesses.version_id IN (#{(versions.ids).join (',')})")
        versions.each do |vers|
        
          vers.user_accesses= accesses.select{|ac| ac.version_id==vers.id}   
         
        end
    
    end


     
    def as_json(options)
    { id: id, text: (name + self.package_id) }
    end
    def version_params params
      params.permit(:name, :description,:version,:folder,:cost,:deleted,:lock_version)
    end
   
  end
end
