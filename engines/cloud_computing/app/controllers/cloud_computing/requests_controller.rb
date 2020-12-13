require_dependency "cloud_computing/application_controller"

module CloudComputing
  class RequestsController < ApplicationController

    before_action only: %i[created_request edit_created_request update_created_request to_sent] do
      @request = user_requests.find_or_initialize_by(status: 'created')
    end

    def index
      @search = user_requests.search(params[:q])
      @requests = @search.result(distinct: true)
                         .order(:created_at)
                         .page(params[:page])
                         .per(params[:per])

    end

    def edit_created_request

    end

    def update_created_request
      if @request.update(request_params)
        redirect_to created_request_requests_path, notice: t('.updated_successfully')
      else
        render :edit_created_request
      end
    end


    def created_request

    end

    def to_sent
      @request.to_sent!
      redirect_to @request
    end

    def cancel
      @request.cancel!
      redirect_to @request
    end


    def show
      @request = user_requests.find(params[:id])
    end

    private

    def user_requests
      Request.where(created_by: current_user)
    end

    def request_params
      params.require(:request).permit(:for_id, :for_type, :comment, :finish_date,
        left_positions_attributes:[:id, :amount, :_destroy, from_links_attributes: %i[id _destroy from_id amount to_item_id]])
    end
  end
end
