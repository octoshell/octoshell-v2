require_dependency "pack/application_controller"

module Pack
  class Admin::AccessesController < Admin::ApplicationController
     autocomplete :package, :name, :full => true
     before_action :access_init, only: [:edit, :show,:update,:destroy]

    def access_init
      @access = Access.find(params[:id])
      @statuses=Access.statuses.keys

    end

    def index
      
      @accesses=Access.page(params[:page]).per(2)#.includes()
      
    end
    
    def show
   
    end

    def new
      @packages=Package.all
      @statuses=Access.statuses.keys
      @access = Access.new
    end

    def create
      @statuses=Access.statuses.keys 
      @hash=access_params.clone
      puts access_params
      if @hash[:who_type]=='User'
        @hash[:who_id]=@hash.delete(:user_id)
      else
        @hash[:who_id]=@hash.delete(:project_id)
      end

      @access = Access.new(@hash)
      @access.user_id=current_user.id
      if @access.save
        redirect_to admin_access_path(@access)
      else
        puts @access.errors.messages[:version_id]
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
      params.require(:access).permit(:proj_or_user, :version_id, :end_lic,:from,:status,:user_id,:project_id,:who_type)   
    end

  end
end
