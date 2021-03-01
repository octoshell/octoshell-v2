module CloudComputing
  class OpennebulaResourceModifier

    def internet_network_id
      settings_hash = Rails.application.secrets.cloud_computing || {}
      settings_hash[:internet_network_id]&.to_s
    end

    def inner_network_id
      settings_hash = Rails.application.secrets.cloud_computing || {}
      settings_hash[:inner_network_id]&.to_s
    end


    def initialize(vm, vm_data)
      @vm = vm
      @vm_data = vm_data
    end

    def log
      return unless @results
      
      @vm.api_logs.create!(item: @vm.item,
                           log: @results,
                           action: callback)

    end

    def success?
      @results.first
    end

    def remove_access_resource_item
      return unless @results && success?

      if @generic_resource.is_a?(ResourceItem) && @generic_resource.item.item_in_access
        @generic_resource.access_resource_item.update!(value: @generic_resource.value)
        @generic_resource.destroy
      end
    end
  end
end
