require_dependency "cloud_computing/application_controller"

module CloudComputing::Admin
  class PositionsController < CloudComputing::Admin::ApplicationController

    def api_logs
      @url = api_logs_admin_position_path(params[:id])
      @search = CloudComputing::ApiLog.search(params[:q])
      @api_logs = @search.result(distinct: true)
                         .where(virtual_machine_id: nil,
                                position_id: params[:id])
                         .order(created_at: :desc)
                         .page(params[:page])
                         .per(params[:per])
      render 'cloud_computing/api_logs/index'
    end
  end
end
