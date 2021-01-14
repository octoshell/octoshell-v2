require 'csv'
module CloudComputing
  class NebulaIdentity < ApplicationRecord

    STATES_AFTER_ACTION = {
      'reboot-hard' => %w[ACTIVE RUNNING],
      'reboot' => %w[ACTIVE RUNNING],
      'poweroff' => %w[shutdown SHUTDOWN_POWEROFF],
      'poweroff-hard' => %w[shutdown SHUTDOWN_POWEROFF],
      'resume' => %w[PENDING LCM_INIT],
      'reinstall' => %w[reinstall CLEANUP_RESUBMIT]
    }.freeze

    ACTIONS = {
      %w[ACTIVE RUNNING] => %w[reboot reboot-hard poweroff poweroff-hard reinstall],
      %w[POWEROFF LCM_INIT] => %w[resume],
      %w[UNDEPLOYED LCM_INIT] => %w[resume],
    }.freeze


    belongs_to :position, inverse_of: :nebula_identities
    has_many :api_logs, inverse_of: :nebula_identity

    validates :identity, uniqueness: true

    def self.human_action(action)
      I18n.t("activerecord.attributes.#{model_name.i18n_key}.actions.#{action}")
    end

    def self.hint_for_action(action)
      I18n.t("activerecord.attributes.#{model_name.i18n_key}.actions.#{action}-hint", default: nil)
    end

    def self.load_states
      @vm_states ||= {}
      @vm_lcm_states ||= {}

      CSV.read("#{CloudComputing::Engine.root}/config/states.csv")[1..-1].each do |a|
        if a[0].present? && a[1].present?
          @vm_states[a[0]] = a[1]
        end
        if a[2].present? && a[3].present?
          @vm_lcm_states[a[2]] = a[3]
        end
      end

    end

    def self.vm_states
      @vm_states || load_states && @vm_states
    end

    def self.vm_lcm_states
      @vm_lcm_states || load_states && @vm_lcm_states
    end



    def change_vm_state(action)
      return false, 'wrong action' unless possible_actions.include?(action)
      if action == 'reinstall'
        result, *arr = OpennebulaClient.vm_reinstall(identity)
      else
        result, *arr = OpennebulaClient.vm_action(identity, action)
      end
      if result
        states = NebulaIdentity::STATES_AFTER_ACTION[action]
        self.state = states[0]
        self.lcm_state = states[1]
        save

        states = Array(previous_changes['state'])
        lcm_states = Array(previous_changes['lcm_state'])

        api_logs.create!(action: "success: #{action}",
                         log: "#{states[0]}  #{lcm_states[0]} => #{states[1]} #{lcm_states[1]}")

      else
        api_logs.create!(action: "failure: #{action}",
                         log: "#{state} #{lcm_state} | #{arr.inspect}")

      end
      [result, arr]
    end

    def vm_info
      result, data, *other = OpennebulaClient.vm_info(identity)
      if result
        hash_data = Hash.from_xml(data)['VM']
        state_code = hash_data['STATE']
        lcm_state_code = hash_data['LCM_STATE']
        self.state = self.class.vm_states[state_code]
        self.lcm_state = self.class.vm_lcm_states[lcm_state_code]
        self.last_info = DateTime.now
        save
        return true
      end

      [false, data, *other]
    end
    attribute :state_from_code
    attribute :lcm_state_from_code

    def state_from_code=(state_code)
      self.state = self.class.vm_states[state_code.to_s]
    end

    def lcm_state_from_code=(lcm_state_code)
      self.lcm_state = self.class.vm_lcm_states[lcm_state_code.to_s]
    end

    def human_last_info
      "#{self.class.human_attribute_name :last_info} #{last_info}"
    end

    def human_state
      "#{state} | #{lcm_state}"
    end

    def possible_actions
      (NebulaIdentity::ACTIONS[[state, lcm_state]] || [])
    end


    def human_possible_actions
      possible_actions.map do |action|
        [action, self.class.human_action(action)]
      end
    end

  end
end
