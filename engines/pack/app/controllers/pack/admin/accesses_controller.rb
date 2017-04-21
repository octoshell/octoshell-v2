require_dependency "pack/application_controller"

module Pack
  class Admin::AccessesController < Admin::ApplicationController
     

    before_action :access_init, only: [:edit, :show,:update,:destroy,:manage_access]

    def access_init
     @access = Access.find(params[:id])
     

    end

    


    def index

      
      @q = Access.ransack(params[:q])
                  
     
      
       @accesses = @q.result.page(params[:page]).per(per_record)
       @accesses = @accesses.preload_who # unless params[:q] && params[:q][:admin_user_access]
       
       
     # @accesses=Access.page(params[:page]).per(per_record).includes(:version).preload_who
      respond_to do |format|
        format.html
        format.js{
          render_paginator(@accesses)
          }
      end
      
    end
    
    def show
     
   
    end

    def manage_access
      
     @access.update access_params.slice(:lock_version,:action) 
    
    end

    def new
      @access = Access.new
      @access.who_type="User"
    end

    

    def create
      
      @access = Access.new access_params
      
      if @access.save
        redirect_to admin_access_path(@access)
      else
        puts @access.errors.to_h
        puts @access.errors.to_h.slice(:version_id,:who)
        add_errors_to_id(@access)
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

    def get_groups
      respond_to do |format|
      format.json do

        
        @records = Group.where("lower(name) like lower(:q)", q: "%#{params[:q].mb_chars}%") 
        render json: { records: @records.page(params[:page])
          .per(params[:per]).map{ |v|  {text: v.name, id: v.id}  }, total: @records.count }
      end
     end
    end


    def destroy
      
      
        @access.destroy
      
      redirect_to admin_accesses_path
    end

    private	
   


  
  	def access_params
      params.require(:access).permit(:who_id,:forever,:action,:lock_version,:proj_or_user, :version_id, 
        :new_end_lic,:end_lic,:from,:status,:user_id,:project_id,:who_type)   
    end

  end
end
