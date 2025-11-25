module Core
  class Admin::AccessesController < Admin::ApplicationController
    # before_action :setup_default_filter
    # before_action :octo_authorize!
    layout "layouts/core/admin_project"
    def index
      @search = Access.ransack(params[:q])
      @search.sorts = 'project_id desc' if @search.sorts.empty?
      @accesses = @search.result(distinct: true)
                                  .select('core_accesses.*, core_accesses.project_id')
                                  .includes([%i[project cluster],
                                            {fields: :quota_kind}]
                                            )
    end

    def show
      @access = Access.find(params[:id])
    end


    def activate_queue
      @queue_access = QueueAccess.find(params[:id])
      @queue_access.activate
      redirect_to admin_access_path(@queue_access.access_id), flash: { info: t('.success') }
    end

    def block_queue
      @queue_access = QueueAccess.find(params[:id])
      @queue_access.block
      redirect_to admin_access_path(@queue_access.access_id), flash: { info: t('.success') }
    end

    private

    def access_params
      params.require(:access).permit(:access_id, :started_at, { partition_ids: [] },
        access_fields_attributes: [:id, :quota_kind_id, :limit])
    end
  end
end
