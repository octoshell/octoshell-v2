module Support
  class FieldOption < ApplicationRecord
    belongs_to :field, inverse_of: :field_options
    # has_many :field_values, through: :field, foreign_key: :value
    before_destroy do
      field.field_values.where(value: id.to_s).destroy_all
    end
    translates :name
    validates_translated :name, presence: true

    def as_json(_options = nil)
      { id: id, text: name }
    end

  end
end
