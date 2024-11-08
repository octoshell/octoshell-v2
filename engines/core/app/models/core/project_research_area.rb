# == Schema Information
#
# Table name: core_research_areas_per_projects
#
#  id               :integer          not null, primary key
#  project_id       :integer
#  research_area_id :integer
#
# Indexes
#
#  iproject_on_ira_per_projects  (project_id)
#  ira_on_ira_per_projects       (research_area_id)
#
module Core
  class ProjectResearchArea < ApplicationRecord
    self.table_name = 'core_research_areas_per_projects'
    belongs_to :project, inverse_of: :project_research_areas
    belongs_to :research_area, inverse_of: :project_research_areas
  end
end
