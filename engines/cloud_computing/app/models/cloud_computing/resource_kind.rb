module CloudComputing
  class ResourceKind < ApplicationRecord
    translates :name, :description, :measurement
    validates_translated :name, :description, :measurement, presence: true
    has_many :resources, inverse_of: :resource_kind
    def name_with_measurement
      "#{name}(#{measurement})"
    end
  end
end
