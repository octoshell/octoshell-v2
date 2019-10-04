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
    belongs_to :field, inverse_of: :field_values
    # belongs_to :field_option, inverse_of: :field_values, foreign_key: :value
    belongs_to :ticket, inverse_of: :field_values

    validates :field, :ticket, presence: true
    validates :value, presence: true, if: :required_value?

    private

    def required_value?
      field.try(:required?)
    end
  end
end
