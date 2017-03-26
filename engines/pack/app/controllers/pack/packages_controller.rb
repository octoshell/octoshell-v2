require_dependency "pack/application_controller"

module Pack
  class PackagesController < ApplicationController
    #before_action :prop_init, only: [:remember_pref, :show]
    

    # GET /packages
    def index
      

      @zz=Packages.joins(:versions).where(versions.t)
      #puts  ( ['packages','versions'].map  { |i| [t(i),i]  } )
      @model_table=params[:type] || 'packages'
      model_table= if @model_table=='packages'
       Package
      else 
        Version.includes(:clustervers)
      end
      @q=model_table.ransack(params[:q])
      @records=@q.result.page(params[:page]).per(2)

      if @model_table=='versions'
        Version.preload_and_to_a(current_user.id,@records) 
        @options_for_select=Core::Project.joins(members: :user).where(core_members: {owner: true}).map do |item|
        [t('project') + ' ' + item.title,item.id]
        end
        @options_for_select<<[t('user'),"user"] 
      end
      #@model_table=params[:version]
      respond_to do |format|


        format.html{
          
        } # index.html.erb
        format.js { 
            
            render_paginator(@records,'#{@model_table}_table')
        }
        format.json do
        @packages = Package.finder(params[:q])    
        render json: { records: @packages.page(params[:page]).per(params[:per]), total: @packages.count }

      
        
      end

      end
      
    end
    def json
      @packages = Package.finder(params[:q])
      @hash=@packages.map do |item|
          {label: item.name, value: item.id}
      end
      render json: @hash

    end

    def show

      
     
      @options_for_select=Core::Project.joins(members: :user).where(core_members: {owner: true}).map do |item|
        [t('project') + ' ' + item.title,item.id]
      end
      @options_for_select<<[t('user'),"user"] 

      @package = Package.find(params[:id])
      @versions = Version.page(params[:page]).per(@per).includes(clustervers: :core_cluster).where(package_id:params[:id])
      #@versions=Version.all.test_preload
      Version.preload_and_to_a(current_user.id,@versions)
     
          

      respond_to do |format|
        format.html
        format.js{
           render_paginator(@versions,'#versions_table')
        }
      end
    end

    def remember_pref
      @pref.def_date=prop_params[:def_date]
      if prop_params[:proj_or_user] == 'user'
        @pref.proj_or_user=prop_params[:proj_or_user]
      else 
         @pref.proj_or_user=Prop.proj_or_users[:project]
         @pref.project_id=prop_params[:proj_or_user]
      end
      @pref.save
      render nothing: "text"
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
