# encoding: utf-8
#
# Название позиции в организации
module Core
  class EmploymentPositionName < ActiveRecord::Base
    validates :name, presence: true, uniqueness: true

    def self.rffi
      find_by_name!("Должность по РФФИ")
    end

    def values(q)
      q = q.to_s.strip
      available_values.find_all do |e|
        e =~ Regexp.new(q)
      end
    end

    def available_values
      return [] if autocomplete.blank?
      autocomplete.each_line.to_a
    end
  end
end
