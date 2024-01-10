module Core
  class ProjectDirectionOfScience < ApplicationRecord
    self.table_name = 'core_direction_of_sciences_per_projects'
    belongs_to :project, inverse_of: :project_direction_of_sciences
    belongs_to :direction_of_science, inverse_of: :project_direction_of_sciences
  end
end
