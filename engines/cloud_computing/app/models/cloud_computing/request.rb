module CloudComputing
  class Request < ApplicationRecord
    belongs_to :configuration, inverse_of: :requests
    belongs_to :for, polymorphic: true
    belongs_to :created_by, class_name: 'User'
    validates :amount, presence: true, numericality: { greater_than: 0 }
    validates :for, :configuration, :configuration_id, presence: true
    validate do
      if configuration && amount > configuration.available
        errors.add :amount, 'error'
      end
    end
  end
end
