module CloudComputing
  class Resource < ApplicationRecord
    belongs_to :resource_kind, inverse_of: :resources
    belongs_to :item, inverse_of: :resources
    validates :resource_kind, :item, :value, presence: true

    def value_with_measurement
      "#{value} #{resource_kind.measurement}"
    end
  end
end
