# == Schema Information
#
# Table name: core_direction_of_sciences_per_projects
#
#  id                      :integer          not null, primary key
#  direction_of_science_id :integer
#  project_id              :integer
#
# Indexes
#
#  idos_on_dos_per_projects      (direction_of_science_id)
#  iproject_on_dos_per_projects  (project_id)
#
module Core
  class ProjectDirectionOfScience < ApplicationRecord
    self.table_name = 'core_direction_of_sciences_per_projects'
    belongs_to :project, inverse_of: :project_direction_of_sciences
    belongs_to :direction_of_science, inverse_of: :project_direction_of_sciences
  end
end
