module CloudComputing
  class OpennebulaDiskSizeModifier < OpennebulaResourceModifier


    def initialize(vm, vm_data)
      super
      @generic_resource = @vm.resource_or_resource_item_by_identity('DISK=>SIZE')
    end

    def callback
      'DISK_RESIZE'
    end

    def rpc_call
      @results = OpennebulaClient.vm_disk_resize(@vm.identity, 0, value)
    end

    def value
      (@generic_resource.value.to_i * 1024).to_s
    end

    def to_change?
      @vm_data['TEMPLATE']['DISK']['SIZE'] != value
    end

    def perform
      if to_change?
        rpc_call
        log
      end
      remove_access_resource_item
    end

  end
end
