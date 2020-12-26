module CloudComputing
  class OpennebulaClient

    def self.init
      Rails.application.secrets.secret_api_key
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

    def self.template_info(template_id)
      xmlrpc_send('template.info', template_id, false, false)
    end

    def self.terminate_vm(vm_id)
      xmlrpc_send('vm.action', 'terminate', vm_id)
    end
#reboot-hard poweroff poweroff-hard найти poweron  найти hard-reset переустановить ОС

    def self.update_context_for_template(template_id, context_hash)
      values = context_hash.map { |key, value| "#{key}=\"#{value}\"" }.join(',')
      context_string = "CONTEXT=[#{values}]"
      xmlrpc_send('template.update', template_id, context_string, 1)
    end

    def self.instantiate_vm(template_id, vm_name, value_string)
      # puts ['template.instantiate', template_id, vm_name, false,
      #             value_string, true].inspect.red

      xmlrpc_send('template.instantiate', template_id, vm_name, false,
                  value_string, true)
    end

  end
end
