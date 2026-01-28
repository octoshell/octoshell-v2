# == Schema Information
#
# Table name: core_employment_positions
#
#  id                          :integer          not null, primary key
#  name                        :string(255)
#  value                       :string(255)
#  created_at                  :datetime
#  updated_at                  :datetime
#  employment_id               :integer
#  employment_position_name_id :integer
#  field_id                    :integer
#
# Indexes
#
#  index_core_employment_positions_on_employment_id  (employment_id)
#

#
# Позиция в организации
module Core
  class EmploymentPosition < ApplicationRecord
    belongs_to :employment, inverse_of: :positions
    belongs_to :employment_position_name
    belongs_to :employment_position_field, foreign_key: :field_id
    validates :employment, presence: true
    validates :value, presence: true, if: proc { field_id.nil? }
    validates :employment_position_field, :field_id, presence: true, if: proc { value.blank? }
    validates :employment_position_name_id, uniqueness: { scope: :employment_id }, if: :employment_id?
    delegate(*EmploymentPositionName.locale_columns(:name), to: :employment_position_name)
    def try_save
      valid? ? save : errors.clear
    end

    delegate :values, :available_values, :hint, to: :employment_position_name

    def name
      return employment_position_name.name if employment_position_name

      super
    end

    def selected_value
      employment_position_field&.name
    end

    def value_to_show
      selected_value || value
    end

    def present_value?
      value.present? || field_id.present?
    end
  end
end
