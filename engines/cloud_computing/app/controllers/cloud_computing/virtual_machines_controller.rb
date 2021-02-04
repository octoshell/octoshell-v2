require_dependency "cloud_computing/application_controller"

module CloudComputing
  class VirtualMachinesController < ApplicationController

    before_action do
      @virtual_machine = CloudComputing::NebulaIdentity.joins(:position)
        .where(cloud_computing_positions: { holder_id: CloudComputing::Access.accessible_by(current_ability, :read) } )
        .find(params[:id])
    end

    def change_state
      result, message = @virtual_machine.change_vm_state(params[:vm_action])
      message = t('.wrong_action') if message == 'wrong action'
      if result
        redirect_to access_path(@virtual_machine.position.holder),
                    flash: { info:  t('.success') }
      else
        redirect_to access_path(@virtual_machine.position.holder),
                    flash: { error: message.inspect }

      end
    end

    def vm_info
      result, data = @virtual_machine.vm_info
      if result
        redirect_to access_path(@virtual_machine.position.holder),
                    flash: { info: t('.success') }
      else
        redirect_to access_path(@virtual_machine.position.holder),
                    flash: { error: data.inspect }

      end
    end

    def api_logs
      @url = api_logs_virtual_machine_path(params[:id])
      @search = @virtual_machine.api_logs.search(params[:q])
      @api_logs = @search.result(distinct: true)
                         .order(created_at: :desc)
                         .page(params[:page])
                         .per(params[:per])
      render 'cloud_computing/api_logs/index'
    end


  end
end
