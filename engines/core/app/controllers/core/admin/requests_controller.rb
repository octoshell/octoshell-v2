module Core
  class Admin::RequestsController < Admin::ApplicationController
    before_action :setup_default_filter, only: :index
    before_action :octo_authorize!

    def index
      @search = Request.search(params[:q])
      @requests = @search.result(distinct: true).order(created_at: :desc).preload(:project)
      without_pagination(:requests)
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

    def activate_or_reject
      @request = Request.find(params[:id])
      unless params[:request][:reason].present?
        flash_message :error, t('.reason_empty')
        redirect_to [:admin, @request]
        return
      end
      if params[:commit] == Core::Request.human_state_event_name(:approve)
        @request.approve
      else
        @request.reject
      end
      @request.reason = params[:request][:reason]
      @request.changed_by = current_user
      @request.save!
      redirect_to [:admin, @request]
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
