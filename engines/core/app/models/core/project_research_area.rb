module Core
  class ProjectResearchArea < ApplicationRecord
    self.table_name = 'core_research_areas_per_projects'
    belongs_to :project, inverse_of: :project_research_areas
    belongs_to :research_area, inverse_of: :project_research_areas
  end
end
