module Core
  class Admin::QueueAccessesController < Admin::ApplicationController
    # before_action :octo_authorize!
    layout "layouts/core/admin_project"
    def index
      @search = QueueAccess.ransack(params[:q])
      @queue_accesses = @search.result(distinct: true)
                               .select('core_queue_accesseses.*, core_accesses.project_id')
                               .includes({access: %i[project cluster],
                                          queue_accesses_fields: :quota_kind},
                                            )
    end


    def choose_access
      return unless params[:project_id] || params[:cluster_id]

      access = Core::Access.find_by(project_id: params[:project_id],
                                    cluster_id: params[:cluster_id])
      if access
        redirect_to new_admin_queue_accesses_path(queue_accesses: { access_id: access.id })
      else
        flash_now_message(:error, t('.not_found'))
      end
    end


    def new
      @queue_access = QueueAccess.new(queue_accesses_params)
      @queue_accesses.build_queue_accesses_fields
    end

    def create
      @queue_accesses = QueueAccess.new(queue_accesses_params)
      if @queue_accesses.save
        redirect_to admin_queue_accesseses_path, flash: { info: t('.success') }
      else
        flash_now_message(:error, @queue_accesses.errors.full_messages.join('. '))

        render :new
      end
    end

    def edit
      @queue_accesses = QueueAccess.find(params[:id])
    end

    def update
      @queue_accesses = QueueAccess.find(params[:id])
      if @queue_accesses.update queue_accesses_params
        redirect_to admin_queue_accesseses_path, flash: { info: t('.success') }
      else
        flash_now_message(:error, @queue_accesses.errors.full_messages.join('. '))
        render :edit
      end
    end

    def fire_event
      @queue_accesses = QueueAccess.find(params[:id])

      @queue_accesses.aasm(:state).fire(params[:event])
      if @queue_accesses.save
        redirect_to admin_queue_accesseses_path, flash: { info: t('.success') }
      else
        redirect_to admin_queue_accesseses_path,
            flash: { error: 'Error happened' }
      end
    end




    private

    def queue_accesses_params
      params.require(:queue_accesses).permit(:access_id, :started_at, { partition_ids: [] },
        queue_accesses_fields_attributes: [:id, :quota_kind_id, :limit])
    end
  end
end
