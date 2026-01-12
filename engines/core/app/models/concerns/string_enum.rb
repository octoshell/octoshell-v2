module StringEnum
  def human_state_name
    self.class.aasm_translate('states', status)
  end

  def human_state_names_with_original_except_mine
    (self.class.statuses.keys - [status]).map { |s| [self.class.aasm_translate('actions', s), s.to_s] }
  end

  def self.included(base)
    base.extend StringEnum::ClassMethods
  end

  module ClassMethods
    def string_enum(statuses)
      enum :status, statuses.map { |v| [v, v.to_s] }.to_h
    end

    def translate_state_path
      'activerecord.string_enum.' + name.downcase.gsub('::', '/')
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

    def human_state_names
      statuses.keys.map { |s| aasm_translate('states', s) }
    end

    def human_state_names_with_original
      statuses.keys.map { |s| [aasm_translate('states', s), s.to_s] }
    end
  end
end
