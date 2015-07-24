module Core
  class Admin::RequestsController < Admin::ApplicationController
    before_filter :setup_default_filter, only: :index

    def index
      @search = Request.search(params[:q])
      @requests = @search.result(distinct: true).order(created_at: :desc).preload(:project).page(params[:page])
    end

    def show
      @request = Request.find(params[:id])
    end

    def edit
      @request = Request.find(params[:id])
    end

    def update
      @request = Request.find(params[:id])
      if @request.update(request_params)
        redirect_to [:admin, @request], notice: t("flash.request_updated")
      else
        render :edit
      end
    end

    def approve
      Request.find(params[:id]).approve!
      redirect_to admin_requests_path
    end

    def reject
      Request.find(params[:id]).reject!
      redirect_to admin_requests_path
    end

    private

    def setup_default_filter
      params[:q] ||= { state_in: ["pending"] }
      params[:q][:meta_sort] ||= "created_at.desc"
    end

    def request_params
      params.require(:request).permit(:cluster_id,
                                      fields_attributes: [:id, :quota_kind_id, :value])
    end
  end
end
