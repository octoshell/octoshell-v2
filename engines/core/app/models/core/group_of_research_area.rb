module Core
  class GroupOfResearchArea < ApplicationRecord
    has_many :research_areas, inverse_of: :group, foreign_key: :group_id
    translates :name
    validates_translated :name, presence: true
    def to_s
      name
    end

    def self.order_by_name_with_areas
      locale_name = [GroupOfResearchArea.current_locale_column(:name)]
      other_names = GroupOfResearchArea.locale_columns(:name) - locale_name
      name_array = locale_name + other_names
      r_name_array = name_array.map { |n| "core_research_areas.#{n}" }
      includes(:research_areas).order(*name_array, *r_name_array)
    end
  end
end
