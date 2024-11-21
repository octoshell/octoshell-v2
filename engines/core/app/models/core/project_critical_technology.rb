# == Schema Information
#
# Table name: core_critical_technologies_per_projects
#
#  id                     :integer          not null, primary key
#  critical_technology_id :integer
#  project_id             :integer
#
# Indexes
#
#  icrittechs_on_critical_technologies_per_projects  (critical_technology_id)
#  iprojects_on_critical_technologies_per_projects   (project_id)
#
module Core
  class ProjectCriticalTechnology < ApplicationRecord
    self.table_name = 'core_critical_technologies_per_projects'
    belongs_to :project, inverse_of: :project_critical_technologies
    belongs_to :critical_technology, inverse_of: :project_critical_technologies 
  end
end
