require_dependency "pack/application_controller"

module Pack
  class PackagesController < ApplicationController
    autocomplete :package, :name, :full => true
    before_action :prop_init, only: [:remember_pref, :show]
    def prop_init
      @pref=Prop.find_by user_id: current_user.id
      print("!!!!!!!!!!!!!" + @pref.def_date + "!!!         " + @pref.project_id.to_s)
    end

    # GET /packages
    def index
      
      respond_to do |format|

        format.html # index.html.erb
        format.js { 
            @model=Package.page(params[:page]).per(2)
            if search_params[:deleted]=="active versions"
              
              @packages=@model.joins(:versions => :clustervers).where(pack_clustervers: {active: true}).select('distinct pack_packages.*')
            else
              @packages = @model.where(search_params).order(:name) 
            end
              
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
      

      
      @a=[t("Create_request"),t("изменить")]
      if !@pref
        @pref=Prop.new
        @pref.user_id=current_user.id
        @pref.user!
        @pref.save
      end
      @pref_form=[[t("user(me)"),:user]] #, [ t("project"),:project]
      @pref_selected= @pref.user? ? :user : @pref.project_id
      Core::Project.joins(members: :user).where(core_members: {owner: true}).find_each do |item|
        @pref_form<<[t('project') + ' ' + item.title,item.id]
       end
       

      
      

      @package = Package.find(params[:id])
       #Arel::Table.new(:photos)
       

       

        @versions = Version.page(params[:page]).per(@per).includes(:clustervers).where(package_id:params[:id])
        Version.preload_and_to_a(current_user.id,@versions)
      respond_to do |format|
        format.html
        format.js 
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
