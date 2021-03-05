module CloudComputing
  class OpennebulaInternetModifier < OpennebulaResourceModifier


    def initialize(vm, vm_data)
      super
      @generic_resource = @vm.resource_or_resource_item_by_identity('internet')
    end

    def callback
      'Internet access'
    end

    def attach?
      return false unless @generic_resource

      [true, '1'].include?(@generic_resource.value)
    end

    def internet_nic
      # pp @vm_data
      nics = @vm_data['TEMPLATE']['NIC']
      nics = [nics] if nics.is_a?(Hash)
      n = nics.detect { |nic| nic['NETWORK_ID'] == internet_network_id }
      n
    end

    def internet_attached?
      internet_nic
    end

    def attach_internet
      return if internet_attached?

      @results = OpennebulaClient.vm_attachnic(@vm.identity, internet_network_id)
      OpennebulaCallback.new(@vm, :assign_internet_ip)
    end

    def detach_internet
      return unless internet_attached?

      @results = OpennebulaClient.vm_detachnic(@vm.identity, internet_nic['NIC_ID'])
      @vm.update!(internet_address: nil)
    end

    def perform
      attach? ? attach_internet : detach_internet
      log
      remove_access_resource_item
    end

  end
end
