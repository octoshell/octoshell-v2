require_dependency "cloud_computing/application_controller"

module CloudComputing::Admin
  class NebulaIdentitiesController < CloudComputing::Admin::ApplicationController

    before_action do
      @nebula_identity = CloudComputing::NebulaIdentity.find(params[:id])
    end

    def change_state
      result, message = @nebula_identity.change_vm_state(params[:vm_action])
      message = t('.wrong_action') if message == 'wrong action'
      if result
        redirect_to admin_access_path(@nebula_identity.position.holder),
                    flash: { info:  t('.success') }
      else
        redirect_to admin_access_path(@nebula_identity.position.holder),
                    flash: { error: message.inspect }

      end
    end

    def vm_info
      result, data = @nebula_identity.vm_info
      if result
        redirect_to admin_access_path(@nebula_identity.position.holder),
                    flash: { info: t('.success') }
      else
        redirect_to admin_access_path(@nebula_identity.position.holder),
                    flash: { error: data.inspect }

      end
    end

    def api_logs
      @url = api_logs_admin_nebula_identity_path(params[:id])
      @search = CloudComputing::ApiLog.search(params[:q])
      @api_logs = @search.result(distinct: true)
                         .where(nebula_identity_id: params[:id])
                         .order(created_at: :desc)
                         .page(params[:page])
                         .per(params[:per])
      render 'cloud_computing/api_logs/index'
    end


  end
end
