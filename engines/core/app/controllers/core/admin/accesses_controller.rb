module Core
  class Admin::AccessesController < Admin::ApplicationController
    # before_action :setup_default_filter
    before_action :octo_authorize!
    layout 'layouts/core/admin_project'
    def index
      @search = Access.ransack(params[:q] || { queue_accesses_id_exists: true })
      @search.sorts = 'project_id desc' if @search.sorts.empty?
      @accesses = @search.result(distinct: true)
                         .select('core_accesses.*, core_accesses.project_id')
                         .page(params[:page])
                         .includes(:project, :cluster,
                                   { resource_controls: {
                                     resource_control_fields: :quota_kind,
                                     resource_control_partitions: :partition
                                   } })
      without_pagination :accesses
    end

    def show
      @access = Access.find(params[:id])
    end

    def edit
      @access = Access.find(params[:id])
      render_edit
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
        @access.resource_controls.each(&:enqueue_synchronize)
        redirect_to admin_access_path(@access), flash: { info: t('.success') }
      else
        render_edit
      end
    end

    def enable_resource_control
      @resource_control = ResourceControl.find(params[:id])
      @resource_control.enable!
      redirect_back(fallback_location: admin_access_path(@resource_control.access_id),
                    info: t('.success'))
    end

    def disable_resource_control
      @resource_control = ResourceControl.find(params[:id])
      @resource_control.disable!
      redirect_back(fallback_location: admin_access_path(@resource_control.access_id),
                    info: t('.success'))
    end

    def destroy_resource_control
      @resource_control = ResourceControl.find(params[:id])
      unless @resource_control.may_destroy?
        redirect_back(fallback_location: admin_access_path(@resource_control.access_id),
                      error: t('.error_not_synced'))
        return
      end
      @resource_control.destroy!
      redirect_back(fallback_location: admin_access_path(@resource_control.access_id),
                    info: t('.success'))
    end

    def sync_resource_controls
      Core::ResourceControl.all.each(&:enqueue_synchronize)
      redirect_to admin_accesses_path
    end

    def calculate_resources
      Core::SshWorker.perform_async(:calculate_resources)
      redirect_to admin_accesses_path
    end

    def send_emails
      Core::ResourceControl.send_resource_usage_emails
      redirect_to admin_accesses_path
    end

    private

    def render_edit
      @access.build_form_defaults
      flash_now_message(:error, @access.errors.full_messages.join('. ')) if @access.errors.any?
      render :edit
    end

    def access_params
      partition_attributes = %i[id _destroy
                                partition_id max_running_jobs
                                max_submitted_jobs]
      params.require(:access).permit({
                                       resource_users_attributes: %i[id member_id email _destroy],
                                       resource_controls_attributes: [:id, :started_at, :status, :_destroy, :note,
                                                                      { resource_control_fields_attributes: %i[id quota_kind_id limit],
                                                                        resource_control_partitions_attributes: partition_attributes }]
                                     })
    end
  end
end
