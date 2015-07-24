# encoding: utf-8
#
# Позиция в организации
module Core
  class EmploymentPosition < ActiveRecord::Base
    belongs_to :employment, inverse_of: :positions

    validates :employment, :name, :value, presence: true
    validates :name, uniqueness: { scope: :employment_id }, if: :employment_id?

    def try_save
      valid? ? save : errors.clear
    end

    delegate :values, :available_values, to: :position_name

    def position_name
      EmploymentPositionName.find_by_name(name) || EmploymentPositionName.new
    end
  end
end
