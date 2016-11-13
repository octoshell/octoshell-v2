require_dependency "pack/application_controller"

module Pack
  class VersionsController < ApplicationController
    before_filter :check_abilities, except: [:index, :show]

    # GET /versions
    

    def new
     
      @version = Version.new()
    end

    def create

      @version = Version.new(version_params)
      @version.package_id=params[:package_id]
      if @version.save
        redirect_to package_path(params[:package_id])
      else
        render :new
      end
    end

    def edit
      @version = Version.find(params[:id])
    end

    def update
      @version = Version.find(params[:id])
      if @version.update(version_params)
        redirect_to package_path(params[:package_id])
      else
        render :edit
      end
    end

    def destroy
      @version = Version.find(params[:id])
      @version.destroy
      redirect_to '/pack'
    end

    private

    def check_abilities
      authorize! :manage, :versions
    end

    def version_params
      params.require(:version).permit(:name, :description,:r_up,:r_down,:active)
    end
  end
end
