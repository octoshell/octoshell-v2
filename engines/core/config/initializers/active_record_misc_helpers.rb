module ActiveRecord
  class Base
#    class << self
#      def human_state_names(n)
#        Hash[aasm(n).states.map do |state|
#          [state.human_name, state.name]
#        end]
#      end
#
#      def state_names(n)
#        aasm(n).states.map &:name
#      end
#    end

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
