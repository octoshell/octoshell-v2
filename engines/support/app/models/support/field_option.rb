module Support
  class FieldOption < ApplicationRecord
    belongs_to :field, inverse_of: :field_options
    # has_many :field_values, through: :field, foreign_key: :value
    before_destroy do
      FieldValue.where(field: field, value: id.to_s).destroy_all
    end
    translates :name
    validates_translated :name, presence: true
  end
end
