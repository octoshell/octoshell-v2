require_dependency "pack/application_controller"

module Pack
  class AccessesController <ApplicationController
    before_action :access_init, only: [:update,:destroy]

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

       @access.update!(new_end_lic: access_params[:new_end_lic])
       
      render nothing: :true
      
    end
  	def form
      if params[:proj_or_user]== 'user'
        @access=Access.find_by(who_id: current_user.id,who_type: 'User',version_id: params[:version_id])
      else
        @access=Access.find_by(who_id: params[:proj_or_user] ,who_type: 'Core::Project',version_id: params[:version_id])
      end
      if (!@access)
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
    end

    def destroy_request
      
      @access=Access.find(params[:id])
      @access.destroy
      render nothing: :true
    end


  



  
      
    	  
    	
    	
  	

  	def access_params
      params.require(:access).permit(:proj_or_user, :version_id, :end_lic,:new_end_lic,:from)   
    end

  end
end
