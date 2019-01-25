# == Schema Information
#
# Table name: support_field_values
#
#  id         :integer          not null, primary key
#  field_id   :integer
#  ticket_id  :integer
#  value      :text
#  created_at :datetime
#  updated_at :datetime
#

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
