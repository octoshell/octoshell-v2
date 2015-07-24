module Core
  class Admin::ClusterLogsController < Admin::ApplicationController
    before_filter :setup_default_filter

    def index
      respond_to do |format|
        format.html do
          @search = ClusterLog.search(params[:q])
          @logs = @search.result(distinct: true).order(:created_at).page(params[:page])
        end
        format.json do
          @logs = ClusterLog.finder(params[:q])
          render json: { records: @logs.page(params[:page]).per(params[:per]), total: @logs.count }
        end
      end
    end

    private

    def setup_default_filter
      params[:q] ||= { cluster_id_eq: -1 }
    end
  end
end
