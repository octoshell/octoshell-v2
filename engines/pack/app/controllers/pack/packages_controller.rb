require_dependency "pack/application_controller"

module Pack
  class PackagesController < ApplicationController
    before_action :prop_init, only: [:remember_pref, :show]
    def prop_init
      @pref=Prop.find_by user_id: current_user.id
    #  print("!!!!!!!!!!!!!" + @pref.proj_or_user)
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
      end
      
    end


    def show
      if !@pref
        @pref=Prop.new
        @pref.user_id=current_user.id
        @pref.user!
        @pref.save
      end
      if (@pref.proj_or_user=="user") 
          @arr=[[t("user(me)"),:user], [ t("project"),:project] ]
        else
          @arr=[[ t("project"),:project],[t("user(me)"),:user] ]
        end
      Version.type="User"
      Version.id=2
      @package = Package.find(params[:id])
       @versions = Version.page(params[:page]).per(2).includes({clustervers: :core_cluster},:user_accesses)
       .where(package_id:params[:id])#.where(pack_accesses: {who_id: current_user.id}).references(:accesses)#where('accesses.who_id=? AND accessed.who_type=User',current_user.id)
      # @user_accesses= Access.where(user_id: current_user.id,who_type: "User")
      # @user_accesses.find_by(who_id: 2)
       # @user_accesses.find_by(who_id: 3)
     # @versions = Version.joins(" 
     # LEFT OUTER JOIN 'pack_clustervers' ON 
      #'pack_clustervers'.'version_id' = 'pack_versions'.'id'
      # LEFT OUTER JOIN 'core_clusters' ON 'core_clusters'.'id' =
      # 'pack_clustervers'.'core_cluster_id' LEFT OUTER JOIN 'pack_accesses' ON 'pack_accesses'.'version_id' = 'pack_
      # versions'.'id' AND (who_type= 'User') WHERE 'pack_versions'.'package_id' = 3")
      #print(@versions.inspect)
      #for @version in @versions
      #print(@version.name)
    #end

      #@clusters=Core::Cluster.all.includes(:pack_clustervers)
    end

    def remember_pref
      
      @pref.proj_or_user=prop_params[:proj_or_user]
      @pref.save
      render nothing: "text"
    end

    
    

    

   
    

    private
      def package_params
        params.require(:package).permit(:name, :folder, :cost,:description,:deleted)
      end
      def prop_params
        params.require(:pref).permit(:proj_or_user)   
      end
    def search_params
      params.require(:search).permit(:deleted)
    end
  end
end
