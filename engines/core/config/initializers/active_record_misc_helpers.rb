module ActiveRecord
  class Base
    class << self
      def human_state_names
        Hash[state_machine.states.map do |state|
          [state.human_name, state.name]
        end]
      end

      def state_names
        state_machine.states.map &:name
      end
    end

    def errors_sentence
      errors.full_messages.to_sentence
    end
  end

  class RecordInProcess < StandardError
  end
end

module Generic
  def to_generic_model
    klass = Class.new(ActiveRecord::Base)
    klass.table_name = table_name
    klass
  end
end

ActiveRecord::Base.extend(Generic)
