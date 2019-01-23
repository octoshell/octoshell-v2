module Hardware
  class StatesLink < ActiveRecord::Base
    belongs_to :from, class_name: "State"
    belongs_to :to, class_name: "State"
    validate do
      errors.add(:from, :invalid) if from.kind != to.kind
    end
  end
end
