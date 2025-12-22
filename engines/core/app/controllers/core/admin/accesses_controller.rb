module Core
  class Admin::AccessesController < Admin::ApplicationController
    # before_action :setup_default_filter
    before_action :octo_authorize!
    layout "layouts/core/admin_project"
    def index
      @search = Access.ransack(params[:q] || { queue_accesses_id_exists: true })
      @search.sorts = 'project_id desc' if @search.sorts.empty?
      @accesses = @search.result(distinct: true)
                         .select('core_accesses.*, core_accesses.project_id')
                          .page(params[:page])
                          .includes(:project, :cluster,
                            {queue_accesses: [:partition, resource_control:{
                              resource_control_fields: :quota_kind }]})
      without_pagination :accesses

    end

    def show
      @access = Access.find(params[:id])
    end

    def edit
      @access = Access.find(params[:id])
      @access.build_queue_accesses
    end

    def update
      @access = Access.find(params[:id])
      @access.assign_attributes access_params
      if params[:add_resource_control]
        @access.resource_controls.new
        render_edit
        return
      end
      if params[:add_resource_user]
        @access.resource_users.build
        render_edit
        return
      end
      if @access.save
        redirect_to admin_access_path(@access), flash: { info: t('.success') }
      else
        render_edit
      end
    end

    def set_queue_status
      @queue_access = QueueAccess.find(params[:id])
      @queue_access.set_status(params[:status])
      redirect_to admin_access_path(@queue_access.access_id), flash: { info: t('.success') }
    end

    def activate_resource_control
      @resource_control = ResourceControl.find(params[:id])
      @resource_control.block_or_activate!
      redirect_back(fallback_location: admin_access_path(@resource_control.access_id),
                    flash: { info: t('.success') })
    end

    def disable_resource_control
      @resource_control = ResourceControl.find(params[:id])
      @resource_control.disable!
      redirect_back(fallback_location: admin_access_path(@resource_control.access_id),
                    flash: { info: t('.success') })
    end

    private

    def render_edit
      @access.build_queue_accesses
      flash_now_message(:error, @access.errors.full_messages.join('. ')) if @access.errors.any?
      render :edit
    end

    def access_params
      queue_access_attributes = %i[id _destroy synced_with_cluster access_id
                                   status partition_id max_running_jobs
                                   max_submitted_jobs]
      params.require(:access).permit({
      resource_users_attributes: %i[id user_id email _destroy],
      resource_controls_attributes: [:id, :started_at, :status, :_destroy,
        resource_control_fields_attributes: %i[id quota_kind_id limit],
         queue_accesses_attributes: queue_access_attributes],
      uncontrolled_queue_accesses_attributes: queue_access_attributes})
    end
  end
end
