require_dependency "pack/application_controller"

module Pack
  class AccessesController <ApplicationController
    
    def access_init
      @access = Access.find(params[:id])
      @statuses=Access.statuses.keys

    end    



    def update
      begin
       
        @vers_id=access_params[:version_id]
        @version=Version.find(@vers_id)
        if @version.service || @version.deleted?
          raise ActiveRecord::RecordNotFound
        end

        @access=Access.user_update(access_params,current_user.id)
        @access.user_edit= true
        @version=@access.version
 
        if @access.save
          @to='success'
          render "form"
        else
           render_template
        end
        rescue ActiveRecord::StaleObjectError
          @message=t("stale_message")
          @access.restore_attributes
          render_template     
        rescue ActiveRecord::RecordNotFound
          @message=t("stale_message") + t("exception_messages.refresh_page")
          render_template     
          
       
          
      end
     
    end
        
      
      
  

    def destroy 
      begin
        @to='delete_success'
        @vers_id=access_params[:version_id]
        @access=Access.find(access_params[:id])
       
        @access.status='deleted' if @access.status=='requested'
        @access.save!
        
      rescue ActiveRecord::StaleObjectError
          @to='delete_not_success'
          @message=t("stale_message") 
      rescue ActiveRecord::RecordNotFound
          @to='delete_not_success'
          @message=t("exception_messages.not_found")    
      end
      render "form"
     
    end
  	def form
      begin
        @vers_id=params[:version_id]
        Version.find(@vers_id)  

        @access=Access.search_access( params,current_user.id)
        render_template 
      rescue ActiveRecord::RecordNotFound
          @message=t("stale_message") + t("exception_messages.refresh_page")
          render "form"
          
      end 
     
    end

    def render_template
      
        if @access    
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
              when 'deleted'
                @to='deleted'
              else
                raise 'Error in @access status'
            end
          end
        end
     
      render "form"

    end

 
  	def access_params
      params.require(:access).permit(:id,:forever,:who_id,:who_type,:proj_or_user, :version_id, :end_lic,:new_end_lic,:from,:lock_version)   
    end

  end

end
