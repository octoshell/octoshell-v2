# TODO выпилить сразу после перехода на https://github.com/troessner/transitions или AASM
module StateMachine
  module Integrations
    module ActiveModel
      public :around_validation
    end

    module ActiveRecord
      public :around_save
    end
  end

  class InvalidTransition < Error
    def initialize(object, machine, event)
      @machine = machine
      @from_state = machine.states.match!(object)
      @from = machine.read(object, :state)
      @event = machine.events.fetch(event)

      if object.errors.any?
        message = object.errors.messages.values.join(', ')
      else
        message = "Cannot transition #{machine.name} via :#{self.event} from #{from_name.inspect}"
      end
      super(object, message)
    end
  end
end

module StateMachineHelpers
  def inside_transition(*args, &callback)
    block = proc do |record, _, event|
      record.transaction do
        event.call
        callback.call(record)
      end
    end
    around_transition(*args, &block)
  end
end
StateMachine::Machine.send(:include, StateMachineHelpers)
