require_dependency "pack/application_controller"

module Pack
  class AccessesController <ApplicationController
    #before_action :access_init, only: [:update,:destroy]

    def access_init
      @access = Access.find(params[:id])
      @statuses=Access.statuses.keys

    end    

  	def create
      if access_params[:from]=='no_admin'
        @type=   access_params[:proj_or_user]== 'user' ?  'User' : 'Core::Project'
        @who_id=   access_params[:proj_or_user]== 'user' ?  current_user.id : access_params[:proj_or_user]
        @user=Access.new do |u|
          u.who_type=@type
          u.who_id=@who_id
          u.user_id=current_user.id
          u.version_id=access_params[:version_id]
          u.requested!
        end
      end
        @user.save!	 
    	render nothing: :true
  	end

    def update
      @access=Access.user_update(access_params,current_user.id)
      @vers_id=access_params[:version_id]
      if @access.save
        @to='success'
        render "form"
      else
        
        render_template
      end
        
      
      #
    end

    def destroy 
      @access=Access.user_update(access_params,current_user.id)
      @vers_id=access_params[:version_id]
      @access.destroy
      @to='success'
      render "form"
      
     
        

    end
  	def form
       @access=Access.search_access( params,current_user.id)
       @vers_id=params[:version_id]
       puts @access.as_json
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
          else
            puts( 'ERROR')  
        end
      end
      render "form"
    end

    def destroy_request
      
      @access=Access.find(params[:id])
      @access.destroy
      render nothing: :true
    end


  



  
      
    	  
    	
    	
  	

  	def access_params
      params.require(:access).permit(:forever,:who_id,:who_type,:proj_or_user, :version_id, :end_lic,:new_end_lic,:from,:expected_status)   
    end

  end
end
