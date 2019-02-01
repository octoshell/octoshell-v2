# encoding: utf-8

# == Schema Information
#
# Table name: core_employment_position_names
#
#  id           :integer          not null, primary key
#  name_ru      :string(255)
#  autocomplete :text
#  created_at   :datetime
#  updated_at   :datetime
#  name_en      :string
#

#
# Название позиции в организации
module Core
  class EmploymentPositionName < ActiveRecord::Base
    validates "name_#{I18n.default_locale}", presence: true, uniqueness: true

    translates :name

    has_many :employment_position_fields, inverse_of: :employment_position_name


    def self.rffi
      find_by_name_ru!("Должность по РФФИ")
    end

    def values(q)
      q = q.to_s.strip
      available_values.find_all do |e|
        e =~ Regexp.new(q)
      end
    end

    def available_values
      employment_position_fields
      # return [] if autocomplete.blank?
      # autocomplete.each_line.to_a
    end
  end
end
