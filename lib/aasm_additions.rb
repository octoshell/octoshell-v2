module AASM_Additions
  def state_name
    state.to_s
  end

  def human_state_name(st=nil)
    st.nil? ? state.to_s : st.to_s
  end

  def self.included(base)
    base.extend AASM_Additions::ClassMethods
  end

  module ClassMethods
    def human_state_event_name s
      s.to_s
    end

    def human_state_name(st=nil)
      st.nil? ? 'none' : st.to_s
    end

    def human_state_names(st=:state)
      aasm(st).states
    end

    def state_names(st=:state)
      aasm(st).states
    end
  end
end

