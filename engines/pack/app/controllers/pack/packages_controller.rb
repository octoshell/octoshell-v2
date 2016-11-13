require_dependency "pack/application_controller"

module Pack
  class PackagesController < ApplicationController
    before_filter :check_abilities, except: [:index, :show]

    # GET /packages
    def index
      @packages = Package.order(:name)
    end

    def show
      @package = Package.find(params[:id])
       @versions = Version.where(package_id:params[:id])
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
      @package.destroy
      redirect_to packages_path
    end

    private

    def check_abilities
      authorize! :manage, :packages
    end

    def package_params
      params.require(:package).permit(:name, :folder, :cost,:description)
    end
  end
end
