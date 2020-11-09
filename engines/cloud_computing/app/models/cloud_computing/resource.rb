module CloudComputing
  class Resource < ApplicationRecord
    belongs_to :resource_kind, inverse_of: :resources
    belongs_to :configuration, inverse_of: :resources
    validates :resource_kind, :configuration, :value, :new_requests, presence: true

    def value_with_measurement
      "#{value} #{resource_kind.measurement}"
    end
  end
end
