require_dependency "pack/application_controller"

module Pack
  class Admin::AccessesController < Admin::ApplicationController
     

    before_action :access_init, only: [:edit, :show,:update,:destroy,:manage_access]

    def access_init
      @access = Access.find(params[:id])
     

    end

    


    def index



      
      #@access=Access.first
      #puts @access.status
     
      @accesses=Access.page(params[:page]).per(per_record).includes(:version)

      #puts @access.aasm.states(:permitted => true)
      respond_to do |format|
        format.html
        format.js{
          #render "helper_templates/render_paginator2",format: :js
          render_paginator(@accesses)
          }
      end
      
    end
    
    def show
     
   
    end

    def manage_access
     
     
     @access.update access_params.slice(:lock_version,:action) 
    
     #@accesses=Access.page(params[:page]).per(per_record).includes(:version)
     #render :index,formats: :js
     
   
    end

    def new
      @access = Access.new
    end

    def create
      @access = Access.new access_params
      if @access.save
        redirect_to admin_access_path(@access)
      else
        #@access.version_id=0
        render :new
      end
    end

    def edit
      
     
    end

    def update
     
      
      if @access.update(access_params)
        redirect_to admin_access_path(@access.id)
      else
        render :edit
      end
    end

    def destroy
      
      
        @access.destroy
      
      redirect_to admin_accesses_path
    end

    private	
  	def access_params
      params.require(:access).permit(:action,:lock_version,:proj_or_user, :version_id, :end_lic,:from,:status,:user_id,:project_id,:who_type)   
    end

  end
end
