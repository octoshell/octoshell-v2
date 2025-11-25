module Core
  class Admin::ResourceControlsController < Admin::ApplicationController
    # before_action :setup_default_filter
    # before_action :octo_authorize!
    layout "layouts/core/admin_project"
    def index
      @search = ResourceControl.ransack(params[:q])
      @search.sorts = 'access_project_id desc' if @search.sorts.empty?
      @resource_controls = @search.result(distinct: true)
                                  .select('core_resource_controls.*, core_accesses.project_id')
                                  .includes({access: %i[project cluster],
                                            resource_control_fields: :quota_kind},
                                            )
    end


    def choose_access
      return unless params[:project_id] || params[:cluster_id]

      access = Core::Access.find_by(project_id: params[:project_id],
                                    cluster_id: params[:cluster_id])
      if access
        redirect_to new_admin_resource_control_path(resource_control: { access_id: access.id })
      else
        flash_now_message(:error, t('.not_found'))
      end
    end


    def new
      @resource_control = ResourceControl.new(resource_control_params)
      @resource_control.build_resource_control_fields
    end

    def create
      @resource_control = ResourceControl.new(resource_control_params)
      if @resource_control.save
        redirect_to admin_resource_controls_path, flash: { info: t('.success') }
      else
        flash_now_message(:error, @resource_control.errors.full_messages.join('. '))

        render :new
      end
    end

    def edit
      @resource_control = ResourceControl.find(params[:id])
    end

    def update
      @resource_control = ResourceControl.find(params[:id])
      if @resource_control.update resource_control_params
        redirect_to admin_resource_controls_path, flash: { info: t('.success') }
      else
        flash_now_message(:error, @resource_control.errors.full_messages.join('. '))
        render :edit
      end
    end

    def fire_event
      @resource_control = ResourceControl.find(params[:id])

      @resource_control.aasm(:state).fire(params[:event])
      if @resource_control.save
        redirect_to admin_resource_controls_path, flash: { info: t('.success') }
      else
        redirect_to admin_resource_controls_path,
                    flash: { error: 'Error happened' }
      end
    end




    private

    def resource_control_params
      params.require(:resource_control).permit(:access_id, :started_at, { partition_ids: [] },
        resource_control_fields_attributes: [:id, :quota_kind_id, :limit])
    end
  end
end
