require_dependency "cloud_computing/application_controller"

module CloudComputing
  class RequestsController < ApplicationController
    def index
      @search = Request.search(params[:q])
      @requests = @search.result(distinct: true).includes(:configuration).page(params[:page])
    end

    def new
      @request = Request.new
    end

    def create
      @request = Request.new(request_params)
      @request.created_by = current_user
      if @request.save
        redirect_to @request
      else
        render :new
      end
    end

    def show
      @request = Request.find(params[:id])
    end

    def destroy
      @cluster = Cluster.find(params[:id])
      @cluster.destroy!
      redirect_to requests_path
    end
    def request_params
      params.require(:request).permit(:comment, :configuration_id, :date,
                                      :for_id, :for_type, :amount)
    end
  end
end
