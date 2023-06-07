module Core
  class ProjectCriticalTechnology < ApplicationRecord
    self.table_name = 'core_critical_technologies_per_projects'
    belongs_to :project, inverse_of: :project_critical_technologies
    belongs_to :critical_technology, inverse_of: :project_critical_technologies 
  end
end
