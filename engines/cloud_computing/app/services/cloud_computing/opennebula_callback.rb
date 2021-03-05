module CloudComputing
  class OpennebulaCallback
    SLEEP_SECONDS = 10

    def internet_network_id
      settings_hash = Rails.application.secrets.cloud_computing || {}
      settings_hash[:internet_network_id]&.to_s
    end

    def inner_network_id
      settings_hash = Rails.application.secrets.cloud_computing || {}
      settings_hash[:inner_network_id]&.to_s
    end

    def initialize(vm, callback, shutdown = false)
      @vm = vm
      @callback = callback
      @shutdown = shutdown
      wait_cycle
    end

    def vm_info
      vm_id = @vm.identity
      results = OpennebulaClient.vm_info(vm_id)
      raise "Error getting vm_info for  #{vm_id}" unless results[0]

      @vm_data = Hash.from_xml(results[1])['VM']
    end

    def assign_inner_ip
      nics = @vm_data['TEMPLATE']['NIC']
      if nics.is_a?(Hash)
        nics = [nics]
      end

      if @vm.inner_address.blank?
        inner_nic = nics.detect { |nic| nic['NETWORK_ID'] == inner_network_id }
        if inner_nic
          ip = inner_nic['IP']
          @vm.update!(inner_address: ip)
        end
      end
    end

    def needed_state?(state, lcm_state)
      if @shutdown
        state == '8'
      else
        state == '3' && lcm_state == '3'
      end
    end

    def error_lcm_states
      (Array(36..42) + [44] + Array(46..50) + [61]).map(&:to_s)
    end

    def error?(state, lcm_state)
      return false if %w[0 1 6 8 9 10 11].include?(state)

      if state == '3' && !error_lcm_states.include?(lcm_state)
        return false
      end

      true
    end


    def check_state
      state = @vm_data['STATE']
      lcm_state = @vm_data['LCM_STATE']
      if @callback.to_sym == :run_if_not && state == '3' && lcm_state == '3'
        true
      elsif needed_state?(state, lcm_state)
        @vm.update!(state_from_code: state, lcm_state_from_code: lcm_state,
                    last_info: DateTime.now)
        send(@callback)
        true
      elsif error?(state, lcm_state)
        @vm.api_logs.create!(item: @vm.item,
                            log: "Error: vm in #{state}:#{lcm_state}",
                            action: @callback)
        true
      else
        false
      end
    end

    def resize_disk
      OpennebulaDiskSizeModifier.new(@vm, @vm_data).perform
    end

    def attach_internet
      OpennebulaInternetModifier.new(@vm, @vm_data).perform
    end

    def resize
      OpennebulaResizeModifier.new(@vm, @vm_data).perform
    end

    def detach_internet
      OpennebulaInternetModifier.new(@vm, @vm_data).detach_internet
    end

    def terminate_vm
      result, *arr = OpennebulaClient.terminate_vm(@vm.identity)
      return 'terminate_vm_error', arr unless result
    end

    def poweroff_hard
      change_state('poweroff-hard', 'change state before resize')
    end

    def run_if_not
      change_state('resume', 'run before any actions')
    end

    def resume
      change_state('resume', 'change state after resize')
      @vm.update!(state_from_code: '3', lcm_state_from_code: '3',
                  last_info: DateTime.now)
    end

    def change_state(state, action)
      results = OpennebulaClient.vm_action(@vm.identity, state)
      @vm.create_log!(results: results, action: action)
    end

    def assign_internet_ip
      nics = @vm_data['TEMPLATE']['NIC']
      if nics.is_a?(Hash)
        nics = [nics]
      end
      internet_nic = nics.detect { |nic| nic['NETWORK_ID'] == internet_network_id }
      ip = internet_nic['IP']
      @vm.update!(internet_address: ip)
    end

    def wait_cycle
      loop do
        vm_info
        assign_inner_ip
        break if check_state

        sleep(SLEEP_SECONDS)
      end
    end
  end
end
