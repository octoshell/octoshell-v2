require_dependency "pack/application_controller"

module Pack
  class AccessesController <ApplicationController
    #before_action :access_init, only: [:update,:destroy]

    def access_init
      @access = Access.find(params[:id])
      @statuses=Access.statuses.keys

    end    



    def update
      @access=Access.user_update(access_params,current_user.id)
      @vers_id=access_params[:version_id]
      @access.allow_create_ticket= true
      @version=@access.version

      if @version.deleted? || @version.service
        render nothing: true
       
      elsif @access.save
        @to='success'
        render "form"
      else
       puts  @access.errors.full_messages
        render_template
      end
        
      
      #
    end

    def destroy 
      @access=Access.user_update(access_params,current_user.id)
      @vers_id=access_params[:version_id]
      @access.destroy
      @to='delete_success'
      render "form"
      
     
        

    end
  	def form
       @access=Access.search_access( params,current_user.id)
       @vers_id=params[:version_id]
       render_template     
     
    end

    def render_template
       if @access.new_record?
        @to='form'
        
      else
        case @access.status
          when 'requested'
            @to='delete'
          when 'allowed'
            @to='allowed'
          when 'denied'
            @to='denied'
          when 'expired'
            @to='allowed'
          else
            raise 'Error in @access status'
        end
      end
      render "form"
    end

    


  



  
      
    	  
    	
    	
  	

  	def access_params
      params.require(:access).permit(:forever,:who_id,:who_type,:proj_or_user, :version_id, :end_lic,:new_end_lic,:from,:lock_version)   
    end

  end
end
