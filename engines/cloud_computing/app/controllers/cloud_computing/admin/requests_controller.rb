require_dependency "cloud_computing/application_controller"

module CloudComputing::Admin
  class RequestsController < CloudComputing::Admin::ApplicationController
    before_action only: %i[refuse show] do
      @request = CloudComputing::Request.find params[:id]
    end

    def index
      @search = CloudComputing::Request.search(params[:q])
      @requests = @search.result(distinct: true)
                         .includes(:created_by, :for)
                         .order(:created_at)
                         .page(params[:page])
                         .per(params[:per])

    end


    def show
    end

    def refuse
      @request.refuse!
      redirect_to [:admin, @request]
    end

    private

    def request_params
      params.require(:request).permit(:for_id, :for_type, :comment, :finish_date,
        left_positions_attributes:[:id, :amount, :_destroy, from_links_attributes: %i[id _destroy from_id amount to_item_id]])
    end
  end
end
