module CloudComputing::Admin
  class VirtualMachinesController < CloudComputing::Admin::ApplicationController

    before_action do
      @virtual_machine = CloudComputing::VirtualMachine.find(params[:id])
    end

    def change_state
      result, message = @virtual_machine.change_vm_state(params[:vm_action])
      message = t('.wrong_action') if message == 'wrong action'
      if result
        redirect_to admin_access_path(@virtual_machine.item.holder),
                    flash: { info:  t('.success') }
      else
        redirect_to admin_access_path(@virtual_machine.item.holder),
                    flash: { error: message.inspect }

      end
    end

    def vm_info
      result, data = @virtual_machine.vm_info
      if result
        redirect_to admin_access_path(@virtual_machine.item.holder),
                    flash: { info: t('.success') }
      else
        redirect_to admin_access_path(@virtual_machine.item.holder),
                    flash: { error: data.inspect }

      end
    end

    def api_logs
      @url = api_logs_admin_virtual_machine_path(params[:id])
      @search = CloudComputing::ApiLog.ransack(params[:q])
      @api_logs = @search.result(distinct: true)
                         .where(virtual_machine_id: params[:id])
                         .order(created_at: :desc)
                         .page(params[:page])
                         .per(params[:per])
      render 'cloud_computing/api_logs/index'
    end


  end
end
