require_dependency "pack/application_controller"

module Pack
  class PackagesController < ApplicationController
    #before_action :prop_init, only: [:remember_pref, :show]
    

    # GET /packages
    # 
    def get_search_form

    end
    def index
  
      @q_form=OpenStruct.new(params[:q] || {user_access: current_user.id})
      @model_table=params[:type] || 'packages'
      model_table= if @model_table=='packages'
       Package.select("pack_packages.*")
      else 
        Version.select("pack_versions.*").includes({clustervers: :core_cluster},:version_options)#.joins(:accesses).where("pack_accesses.status = 'expired'")
      end
      


      if @model_table=='packages' 
        permanent = [:user_access,:deleted_eq,:id_in]
        q_hash=Hash[@q_form.to_h.except(*permanent)
          .map{ |key,val| ["versions_#{key}",val]  }].
          merge @q_form.to_h.slice(*permanent)  
      else 
        q_hash = @q_form.to_h
        q_hash[:package_deleted_eq] =q_hash[:deleted_eq]
        @options_for_select=Core::Project.joins(members: :user).where(core_members: {owner: true}).map do |item|
        [t('project') + ' ' + item.title,item.id]
        end
        @options_for_select<<[t('user'),"user"] 
      end

      @q=model_table.ransack(q_hash)
     
      @records=@q.result(distinct: true).order(:id)
      if q_hash[:user_access]=='0'
        puts "ZZZZZ"
        if @model_table=='packages'
          @records =  @records.joins(<<-eoruby
          LEFT JOIN pack_versions ON pack_versions.package_id = pack_packages.id
          eoruby

          )

        end
        @records=@records.merge( Version.joins_user_accesses(current_user.id))

      end
       @records=@records.allowed_for_users(current_user.id).page(params[:page]).per(6)

       Version.preload_and_to_a(current_user.id,@records)  if @model_table=='versions'

   

     
      
      respond_to do |format|


        format.html{
          
        } # index.html.erb
        format.js { 
            
            render_paginator(@records,"#{@model_table}_table")
        }
        format.json do
          @packages = Package.finder(params[:q])    
          render json: { records: @packages.page(params[:page]).per(params[:per]), total: @packages.count } 
        end

      end
      
    end
    def json
        @packages = Package.finder(params[:q])    
        render json: { records: @packages.page(params[:page]).per(params[:per]), total: @packages.count } 

    end

    def show

      
    
      @options_for_select=Core::Project.joins(members: :user).where(core_members: {owner: true}).map do |item|
        [t('project') + ' ' + item.title,item.id]
      end
      @options_for_select<<[t('user'),"user"] 

      @package = Package.find(params[:id])
      @versions = @package.versions.allowed_for_users(current_user.id).joins_user_accesses(current_user.id).order(:id).page(params[:page]).per(6).includes(clustervers: :core_cluster).uniq
      Version.preload_and_to_a(current_user.id,@versions)
      
      respond_to do |format|
        format.html
        format.js{
           render_paginator(@versions,'versions_table')
        }
      end
    end

    
    
    

    

   
    

    private
      def package_params
        params.require(:package).permit(:name, :folder, :cost,:description,:deleted)
      end
      def prop_params
        params.require(:pref).permit(:proj_or_user,:def_date)   
      end
    def search_params
      params.require(:search).permit(:deleted)
    end
  end
end
