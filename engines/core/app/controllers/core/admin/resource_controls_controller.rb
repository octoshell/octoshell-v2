module Core
  class Admin::ResourceControlsController < Admin::ApplicationController
    # before_action :setup_default_filter
    # before_action :octo_authorize!
    def index
      @search = ResourceControl.search(params[:q])
      @resource_controls = @search.result(distinct: true)
                                  .includes(access: %i[project cluster],
                                            resource_control_fields: :quota_kind,
                                            queue_accesses: :partition)
                              #    .joins(:access)
                              #    .order('core_accesses.project_id ASC, core_accesses.cluster_id ASC')
      # @spans = Array.new(@resource_control.count)
      # prev_index = false
      # prev_index = false
      # @resource_control.each_with_index do |r, i|
      #
      # end

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

    private

    def resource_control_params
      params.require(:resource_control).permit(:access_id, :started_at, {partition_ids_setter: []},
        resource_control_fields_attributes: [:id, :quota_kind_id, :limit])
    end
  end
end
