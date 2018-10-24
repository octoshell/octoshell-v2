module Hardware
  class StatesLink < ActiveRecord::Base
    belongs_to :from, class_name: "State"
    belongs_to :to, class_name: "State"

  end
end
