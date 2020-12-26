require_dependency "cloud_computing/application_controller"

module CloudComputing
  class ResourceKindsController < ApplicationController

    def show
      @resource_kind = ResourceKind.find(params[:id])
      respond_to do |format|
        format.html
        format.json { render json: @resource_kind }
      end
    end
    
  end
end
