module CloudComputing
  class OpennebulaTask
    SLEEP_SECONDS = 10

    def self.internet_network_id
      settings_hash = Rails.application.secrets.cloud_computing || {}
      settings_hash[:internet_network_id]&.to_s
    end

    def self.inner_network_id
      settings_hash = Rails.application.secrets.cloud_computing || {}
      settings_hash[:inner_network_id]&.to_s
    end


    def self.ssh_public_keys(access)
      Core::Credential.active.where(user_id: access.for.members.allowed
          .select('user_id')).select('public_key').map(&:public_key)
    end

    def self.add_keys(access_id)
      @access = CloudComputing::Access.find(access_id)
      key_string = ssh_public_keys(@access).uniq.join("\n")
      @access.virtual_machines.each do |n_i|
        vm_id = n_i.identity
        result, *arr = OpennebulaClient.vm_info(vm_id)
        unless result
          @access.api_logs.create!(log: arr.inspect, action: 'vm_info_error')
        end
        info = Hash.from_xml(arr[0])['VM']
        context = info['TEMPLATE']['CONTEXT']
        context['SSH_PUBLIC_KEY'] = key_string
        values = context.map { |key, value| "#{key}=\"#{value}\"" }.join(',')
        context_string = "CONTEXT=[#{values}]"
        result, *arr = OpennebulaClient.vm_updateconf(vm_id, context_string)
        unless result
          @access.api_logs.create!(log: arr.inspect, action: 'updateconf_error')
        end
      end
    end

    def self.each_vm(access)
      VirtualMachine.where(item: access.new_left_items).each do |n_i|
        yield(n_i)
      end
    end

    def self.instantiate_access(access_id)
      access = Access.find(access_id)
      ssh = ssh_public_keys(access).join("\n")
      access.new_left_items.includes(:template).each do |item|
        instantiate_vm(item, ssh)
      end

      begin

        each_vm(access) do |n_i|
          OpennebulaCallback.new(n_i, :run_if_not)
        end

        each_vm(access) do |n_i|
          OpennebulaCallback.new(n_i, :resize_disk)
        end

        each_vm(access) do |n_i|
          OpennebulaCallback.new(n_i, :attach_internet)
        end

        each_vm(access) do |n_i|
          OpennebulaCallback.new(n_i, :poweroff_hard)
        end

        each_vm(access) do |n_i|
          OpennebulaCallback.new(n_i, :resize, true)
        end

        each_vm(access) do |n_i|
          OpennebulaCallback.new(n_i, :resume, true)
        end
      ensure
        access.old_left_items.each do |item|
          item.destroy if item.resource_items.empty?
        end
      end
    end

    def self.instantiate_vm(item, ssh)
      template_id = item.template.identity
      results = OpennebulaClient.template_info(template_id)
      return results unless results[0]

      hash = {}
      hash['CONTEXT'] = Hash.from_xml(results[1])['VMTEMPLATE']['TEMPLATE']['CONTEXT'] || {}
      hash['CONTEXT']['SSH_PUBLIC_KEY'] = ssh
      hash['USER'] = 'root'
      hash['OCTOSHELL_BOUND_TO_TEMPLATE'] = 'OCTOSHELL_BOUND_TO_TEMPLATE'

      hash_from_item(hash, item)
      value_string = to_value_string(hash, "\n")
      unless item.virtual_machine
        n_i = item.create_virtual_machine!(state: 'initial', last_info: DateTime.now)
        name = "octo-#{item.holder.id}-#{item.id}-#{n_i.id}"
        results = OpennebulaClient.instantiate_vm(template_id, name, value_string)
        if results[0]
          n_i.update!(identity: results[1])
          n_i.api_logs.create!(action: 'on_create', log: results, item: n_i.item)
        else
          n_i.destroy
          item.api_logs.create!(log: results, action: 'on_create')
        end
      end
    end

    def self.terminate_vm(vm)
      result, *arr = OpennebulaClient.terminate_vm(vm.identity)
      return 'terminate_vm_error', arr unless result
    end

    def self.terminate_template(n_i)
      instance_id = n_i.identity
      loop do
        result, *arr = OpennebulaClient.vm_info(instance_id)
        return 'vm_info_error', arr unless result

        info = Hash.from_xml(arr[0])['VM']
        template_id = info['TEMPLATE']['TEMPLATE_ID'].to_i
        state = info['STATE']
        lcm_state = info['LCM_STATE']

        n_i.update!(state_from_code: state, lcm_state_from_code: lcm_state,
                    last_info: DateTime.now)

        unless state == '6'
          sleep(SLEEP_SECONDS)
          next
        end

        result, *arr = OpennebulaClient.delete_template(template_id)
        return 'delete_template_error', arr unless result

        return 'success'
      end
    end

    def self.finish_access(access_id)
      access = Access.find(access_id)
      nis = VirtualMachine.where(item: access.new_left_items)

      nis.each do |n_i|
        OpennebulaCallback.new(n_i, :run_if_not)
      end

      nis.each do |n_i|
        OpennebulaCallback.new(n_i, :detach_internet)
      end

      nis.each do |n_i|
        OpennebulaCallback.new(n_i, :terminate_vm)
      end

    end

    def self.terminate_access(access_id)
      access = Access.find(access_id)
      VirtualMachine.where(item: access.new_left_items).each do |n_i|
        terminate_template(n_i)
      end
    end


    def self.to_value_string(hash, delim)
      hash.map do |key, value|
        if value.is_a? Hash
          "#{key}=[#{to_value_string(value, ',')}]"
        else
          "#{key}=\"#{value}\""
        end
      end.join(delim)
    end

    def self.hash_from_item(hash, item)
      item.resource_items.with_identity.each do |r_p|
        assign_identity(hash, r_p.resource.resource_kind.identity, r_p.value)
      end
      item.template.resources.where(editable: false).each do |resource|
        assign_identity(hash, resource.resource_kind.identity, resource.value)
      end
      hash
    end

    def self.assign_identity(hash, identity, value)
      if identity == 'MEMORY'
        hash['MEMORY'] = (value.to_i * 1024).to_i
      elsif identity == 'CPU'
        hash['CPU'] = value.to_f
        hash['VCPU'] = value.to_i
      end
    end

    def self.get_setting(value)
      settings_hash = Rails.application.secrets.cloud_computing || {}
      settings_hash[value]
    end

  end
end
