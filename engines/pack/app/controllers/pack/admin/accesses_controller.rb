require_dependency "pack/application_controller"

module Pack
  class Admin::AccessesController < Admin::ApplicationController
     
    rescue_from ActiveRecord::RecordNotFound do |ex|
      render "not_found"
    end
    before_action :access_init, only: [:edit, :show,:update,:destroy]

    def access_init
     @access = Access.preload_who.find(params[:id])
     

    end

    


    def index

      
           
      @q = Access.ransack(params[:q])
                  
     
      
       @accesses = @q.result.page(params[:page]).per(20).preload_who.includes(:version)
        # unless params[:q] && params[:q][:admin_user_access]
       
       #v= @accesses.first.tickets.create!(subject: 'test',reporter: current_user,message: 'test',topic_id: Access.support_access_topic_id )
       
       
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
      
      
      begin
        access_init
        if access_params[:action]=='edit_by_hand'
          @access.attributes= access_params.slice(:lock_version,:forever,:end_lic) 
        else
          @access.attributes= access_params.slice(:lock_version,:action)
        end 
        if @access.save

        
          @to='successful'

        else
          @to='manage_access'
        end

        rescue ActiveRecord::StaleObjectError
          @to='manage_access'
          @message=t("stale_message") 
          @access.restore_attributes
        rescue ActiveRecord::RecordNotFound
          @to='manage_access'
          @message= t("exception_messages.not_found") + t("exception_messages.not_found")
        
      end
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
