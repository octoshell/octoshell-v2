# == Schema Information
#
# Table name: core_employment_position_fields
#
#  id                          :integer          not null, primary key
#  employment_position_name_id :integer
#  name_ru                     :string
#  name_en                     :string
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#

module Core
  class EmploymentPositionField < ActiveRecord::Base
    belongs_to :employment_position_name, inverse_of: :employment_position_fields
    validates :employment_position_name_id, uniqueness: { scope: :name_ru }
    translates :name
    validates "name_#{I18n.default_locale}", :employment_position_name, presence: true
  end
end
