module CloudComputing
  class OpennebulaResourceModifier

    def internet_network_id
      settings_hash = Rails.configuration.secrets[:cloud_computing] || {}
      settings_hash[:internet_network_id]&.to_s
    end

    def inner_network_id
      settings_hash = Rails.configuration.secrets[:cloud_computing] || {}
      settings_hash[:inner_network_id]&.to_s
    end


    def initialize(vm, vm_data)
      @vm = vm
      if vm_data
        @vm_data = vm_data
      else
        vm_id = @vm.identity
        results = OpennebulaClient.vm_info(vm_id)
        raise "Error getting vm_info for  #{vm_id}" unless results[0]
        @vm_data = Hash.from_xml(results[1])['VM']
      end
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

    def remove?
      !@results || success?
    end

    def remove_access_resource_item
      return unless remove?

      if @generic_resource.is_a?(ResourceItem) && @generic_resource.item.item_in_access
        @generic_resource.access_resource_item.update!(value: @generic_resource.value)
        @generic_resource.destroy
      end
    end
  end
end
