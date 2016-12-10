require_dependency "pack/application_controller"

module Pack
  class Admin::PackagesController < Admin::ApplicationController
    before_filter :check_abilities, except: [:index, :show]

    # GET /packages
    def index
      
      respond_to do |format|

        format.html # index.html.erb
        format.json { 
            if search_params[:deleted]=="active versions"
              
              @packages=Package.joins(:versions => :clustervers).where(pack_clustervers: {active: true}).select('distinct pack_packages.*')
            else
              @packages = Package.where(search_params).order(:name) 
            end
         
                  
          render :json => @packages}
      end
      
    end


    def show

      @package = Package.find(params[:id])
       @versions = Version.where(package_id:params[:id])
      @myvers = Clusterver.all
    end

    def new
      @package = Package.new
    end

    def create
      @package = Package.new(package_params)
      if @package.save
        redirect_to @package
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
        redirect_to @package
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
      redirect_to packages_path
    end

    private

    def check_abilities
      authorize! :manage, :packages
    end

    def package_params
      params.require(:package).permit(:name, :folder, :cost,:description,:deleted)   
    end
    def search_params
      params.require(:search).permit(:deleted)
    end
  end
end
