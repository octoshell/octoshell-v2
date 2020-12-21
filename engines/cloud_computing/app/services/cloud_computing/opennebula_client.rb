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

    def self.update_context_for_template(template_id, context_hash)
      values = context_hash.map { |key, value| "#{key}=\"#{value}\"" }.join(',')
      context_string = "CONTEXT=[#{values}]"
      xmlrpc_send('template.update', template_id, context_string, 1)
    end

    def self.instantiate_vm(template_id, vm_name, value_string)
      xmlrpc_send('template.instantiate', template_id, vm_name, false,
                  value_string, false)
    end

    def self.updateconf(instance_id)
      # results = vm_info(instance_id)
      # Nokogiri::XML(results[1])
      # string = "CONTEXT=[NAME=root,PASSWORD=bad_pass]"
      # xmlrpc_send('vm.updateconf', instance_id, string)
    end
# CONTEXT=[SSH_PUBLIC_KEY=ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDKVpmQDCV15kRkthDQmWntTgxlIkbHg6JS2omdevoy0kr1plXquAQfiiWyYhwwigIF8Mpgk3g0sdtWuAUI3LZZWrzTFkWk3c3B/Anqk3qBaX8JDcVUaUMa
    # def self.method_missing(method, *args, &block)
    #   methods = %i[template_list instantiate_vm]
    #   return super unless methods.include? method
    #
    #   @instance ||= new
    #   method, *args = @instance.public_send(method, *args, &block)
    #   results = @instance.xmlrpc_send(method, args)
    #   puts 'aaa'.red
    #   status = results[0]
    #   # @instance.xmlrpc_send()
    #   if status
    #     Hash.from_xml(results[1])
    #   else
    #     results
    #   end
    # end
  end
end
