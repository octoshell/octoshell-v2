module CloudComputing
  class OpennebulaResizeModifier < OpennebulaResourceModifier

    def perform
      if to_change?
        rpc_call
        log
      end
      remove_access_resource_items
    end

    def initialize(vm, vm_data)
      super
      @generic_resources = %w[CPU MEMORY].map do |identity|
        resource = @vm.resource_or_resource_item_by_identity(identity)
        server_value = @vm_data['TEMPLATE'][identity]
        resource_value = resource.value
        resource_value = resource_value.to_f * 1024 if identity == 'MEMORY'
        next if !resource || resource_value.to_f == server_value.to_f

        [identity, resource]
      end.compact.to_h
    end

    def callback
      'RESIZE'
    end

    def str_argument
      hash = @generic_resources.map do |key, resource|
        resource_value = resource.value
        resource_value = resource_value.to_f * 1024 if key == 'MEMORY'
        [key, resource_value]
      end.compact.to_h
      cpus = hash['CPU']
      hash['VCPU'] = cpus if cpus
      hash.map { |key, r| "#{key}=\"#{r}\"" }.join("\n")
    end

    def rpc_call
      @results = OpennebulaClient.vm_resize(@vm.identity, str_argument)
    end

    def to_change?
      @generic_resources.any?
    end

    def remove_access_resource_items
      return unless remove?

      @generic_resources.values.each do |resource|
        if resource.is_a?(ResourceItem) && resource.item.item_in_access
          resource.access_resource_item.update!(value: resource.value)
          resource.destroy
        end
      end
    end

  end
end
