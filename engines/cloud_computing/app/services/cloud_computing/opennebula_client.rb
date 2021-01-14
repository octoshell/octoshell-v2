module CloudComputing
  class OpennebulaClient

    def self.init
      settings_hash = Rails.application.secrets.cloud_computing || {}
      uri = settings_hash[:opennebula_api_uri]
      return unless uri

      @server = XMLRPC::Client.new2(uri)
      @session_string = settings_hash[:session_string]
    end

    init



    def self.xmlrpc_send(*args)
      @server.call('one.' + args.first, @session_string, *args.slice(1..-1))
    end

    def self.template_list
      xmlrpc_send('templatepool.info', -3, -1, -1)
    end

    def self.delete_template(template_id)
      xmlrpc_send('template.delete', template_id, true)
    end

    def self.template_info(template_id)
      xmlrpc_send('template.info', template_id, false, false)
    end


    def self.vm_action(vm_id, state)
      xmlrpc_send('vm.action', state, vm_id)
    end

    def self.vm_updateconf(vm_id, string)
      xmlrpc_send('vm.updateconf', vm_id, string)
    end


    def self.vm_reinstall(vm_id)
      xmlrpc_send('vm.recover', vm_id, 4)
    end


    def self.terminate_vm(vm_id)
      xmlrpc_send('vm.action', 'terminate-hard', vm_id)
    end

    def self.update_context_for_template(template_id, context_hash)
      values = context_hash.map { |key, value| "#{key}=\"#{value}\"" }.join(',')
      context_string = "CONTEXT=[#{values}]"
      xmlrpc_send('template.update', template_id, context_string, 1)
    end

    def self.instantiate_vm(template_id, vm_name, value_string)
      xmlrpc_send('template.instantiate', template_id, vm_name, false,
                  value_string, true)
    end

    def self.vm_info(vm_id)
      xmlrpc_send('vm.info', vm_id, false)
    end

    def self.vm_disk_resize(vm_id, disk_id, size)
      xmlrpc_send('vm.diskresize', vm_id, disk_id, size)
    end

  end
end
