# == Schema Information
#
# Table name: core_research_areas
#
#  id         :integer          not null, primary key
#  name_ru    :string(255)
#  group      :string(255)
#  created_at :datetime
#  updated_at :datetime
#  name_en    :string
#

module Core
  class ResearchArea < ApplicationRecord
    has_and_belongs_to_many :projects, join_table: "core_research_areas_per_projects"

    translates :name
    validates_translated :name, presence: true
    def to_s
      name
    end
  end
end
