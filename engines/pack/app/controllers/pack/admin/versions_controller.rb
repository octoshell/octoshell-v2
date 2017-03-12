require_dependency "pack/application_controller"

module Pack
  class Admin::VersionsController < Admin::ApplicationController
    before_action :pack_init, except: [:index]


    # GET /versions
    

    def index
      
      respond_to do |format|
      format.json do

        @versions = Version.finder(params[:q]).page(params[:page]).per(params[:per]).includes(:package)
        @hash=[]
        @versions.each do |item|
        
        @hash<<{ text: item.name +  "   #{t('Package_name')}: #{item.package.name}", id: item.id }
        end        
        render json: { records: @hash, total: @versions.count }

      
        
      end
      end
    end

    def new  
      @version = Version.new
      
      
    end

    def create
      #puts  clusters_params[:clusters]
      #@par=params[:version].delete(:clusters)
      @version = Version.new
      @version.package=@package
      if @version.vers_update(params) 
       
        
        redirect_to admin_package_path(@package)

      else
        
        render :new
      end
    end

    def edit
      
     
      @version = Version.includes(clustervers: :core_cluster).find(params[:id]) 
      @version.errors.add(:base,:deleted_record) 
        @version.errors.each do |k,v|
          puts v
        end
      
    end
    
    




    





   
    
   

    def update
      

      
      @version = Version.includes({clustervers: :core_cluster}).find(params[:id])
      
      
      #@version.version_options_my_attributes=params[:version][:version_options_attributes]
      #@version.update_clustervers params[:version][:my_clustervers]
      #VersionOption.create!(name: 'second',value: 'value',version_id: @version.id)
      #@version.clustervers_attributes=clustervers_update(params[:version][:p_clvers]) 
      if @version.vers_update(params)
        
        redirect_to admin_package_path(@package)
      else
        #puts @version.errors.messages
         
        
        render :edit
      end
    end

    def show
      
      @version = Version.find(params[:id])
      
    
    end

    def destroy
      @version = Version.find(params[:id])
      @version.destroy
      redirect_to admin_package_path(@package)
    end

    private

    def pack_init
     @package = Package.find(params[:package_id])
    end

    
    def test_params
      #params.require(:version).permit(:version_options_attributes)
    end
  end
end
