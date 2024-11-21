# == Schema Information
#
# Table name: support_field_options
#
#  id         :bigint(8)        not null, primary key
#  name_en    :text
#  name_ru    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  field_id   :bigint(8)
#
# Indexes
#
#  index_support_field_options_on_field_id  (field_id)
#
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
