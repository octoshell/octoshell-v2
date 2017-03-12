require_dependency "pack/application_controller"

module Pack
  class Admin::PackagesController < Admin::ApplicationController

    # GET /packages
    def index
    
      
      respond_to do |format|

        format.html # index.html.erb
        format.js { 
            @model=Package.page(params[:page]).per(@per)
            if search_params[:deleted]=="active versions"
              
              @packages=@model.joins(:versions => :clustervers).where(pack_clustervers: {active: true}).select('distinct pack_packages.*')
            else
              @packages = @model.where(search_params).order(:name) 
            end
         
              
        }
      end
      
    end


    def show


      @package = Package.find(params[:id])



      @versions=@package.versions.page(params[:page]).per(@per).includes(clustervers: :core_cluster)
      
      
      
    end

    def new
      @package = Package.new
    end

    def create
      @package = Package.new(package_params)
      if @package.save
        redirect_to admin_package_path(@package.id)
      else
        render :new
      end
    end

    def edit
      @package = Package.find(params[:id])

    end

    def update
      
      @package = Package.find(params[:id])
      
      if @package.update(package_params)
        redirect_to admin_package_path(@package.id)
      else
      
        render :edit
      end
    end

    def destroy
      @package = Package.find(params[:id])
      if @package.deleted
        @package.destroy
      else
        @package.deleted =  true
        @package.save
      end
      redirect_to admin_packages_path
    end

    private

   

    def package_params
      params.require(:package).permit(:name, :folder, :cost,:description,:deleted,:lock_version)   
    end
    def search_params
      params.require(:search).permit(:deleted)
    end
  end
end
