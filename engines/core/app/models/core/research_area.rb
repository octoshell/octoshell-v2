module Core
  class ResearchArea < ActiveRecord::Base
    has_and_belongs_to_many :projects, join_table: "core_research_areas_per_projects"

    def to_s
      name
    end
  end
end
