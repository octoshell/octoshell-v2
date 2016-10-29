module Support
  class FieldValue < ActiveRecord::Base
    belongs_to :field
    belongs_to :ticket, inverse_of: :field_values

    validates :field, :ticket, presence: true
    validates :value, presence: true, if: :required_value?

    private

    def required_value?
      field.try(:required?)
    end
  end
end
