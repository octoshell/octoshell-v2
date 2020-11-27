# == Schema Information
#
# Table name: support_field_values
#
#  id         :integer          not null, primary key
#  value      :text
#  created_at :datetime
#  updated_at :datetime
#  field_id   :integer
#  ticket_id  :integer
#
# Indexes
#
#  index_support_field_values_on_ticket_id  (ticket_id)
#

module Support
  class FieldValue < ApplicationRecord
    # belongs_to :field, through: :topics_field
    belongs_to :topics_field, inverse_of: :field_values

    belongs_to :_field_option, foreign_key: :value, class_name: FieldOption.to_s

    # belongs_to :field_option, inverse_of: :field_values, foreign_key: :value
    belongs_to :ticket, inverse_of: :field_values

    validates :field, :topics_field, presence: true
    validates :value, presence: true, if: :required_value?

    def required_value?
      topics_field && topics_field.required
    end

    def field
      topics_field && topics_field.field
    end

    def field_option_name
      _field_option && _field_option.name
    end

  end
end
