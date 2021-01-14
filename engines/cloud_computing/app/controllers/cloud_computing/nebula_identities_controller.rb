require_dependency "cloud_computing/application_controller"

module CloudComputing
  class NebulaIdentitiesController < ApplicationController

    before_action do
      @nebula_identity = CloudComputing::NebulaIdentity.joins(:position)
        .where(cloud_computing_positions: { holder_id: CloudComputing::Access.accessible_by(current_ability, :read) } )
        .find(params[:id])
    end

    def change_state
      result, message = @nebula_identity.change_vm_state(params[:vm_action])
      message = t('.wrong_action') if message == 'wrong action'
      if result
        redirect_to access_path(@nebula_identity.position.holder),
                    flash: { info:  t('.success') }
      else
        redirect_to access_path(@nebula_identity.position.holder),
                    flash: { error: message.inspect }

      end
    end

    def vm_info
      result, data = @nebula_identity.vm_info
      if result
        redirect_to access_path(@nebula_identity.position.holder),
                    flash: { info: t('.success') }
      else
        redirect_to access_path(@nebula_identity.position.holder),
                    flash: { error: data.inspect }

      end
    end

    def api_logs
      @url = api_logs_nebula_identity_path(params[:id])
      @search = @nebula_identity.api_logs.search(params[:q])
      @api_logs = @search.result(distinct: true)
                         .order(created_at: :desc)
                         .page(params[:page])
                         .per(params[:per])
      render 'cloud_computing/api_logs/index'
    end


  end
end
