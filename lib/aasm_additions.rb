module AASM_Additions
  def state_name
    send(self.class.state_key).to_s
  end

  def human_state_name(st = nil)
    st.nil? ? self.class.aasm_translate('states', send(self.class.state_key)).to_s : st.to_s
  end

  def self.included(base)
    base.extend AASM_Additions::ClassMethods
  end

  module ClassMethods

    def state_key
      array = AASM::StateMachineStore[name].keys
      raise "Don't use AASM_Additions with >1 aasm columns" if array.count > 1
      array.first
    end

    def translate_state_path
      'activerecord.aasm.' + name.downcase.gsub('::', '/') + '.' + state_key
    end

    def aasm_translate(*args)
      I18n.t("#{translate_state_path}.#{args.join '.'}")
    end

    def human_state_event_name(s)
      aasm_translate('events', s).to_s
    end

    def human_state_name(st = nil)
      st.nil? ? 'none' : aasm_translate('states', st).to_s
    end

    def human_state_names(st = :state)
      aasm(st).states.map { |s| aasm_translate('states', s) }
    end

    def human_state_names_with_original(st = :state)
      aasm(st).states.map { |s| [aasm_translate('states', s), s.to_s] }
    end

    def state_names(st=:state)
      aasm(st).states
    end
  end
end
