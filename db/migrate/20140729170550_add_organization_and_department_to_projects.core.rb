# This migration comes from core (originally 20140729170406)
class AddOrganizationAndDepartmentToProjects < ActiveRecord::Migration[4.2]
  def change
    add_column :core_projects, :organization_id, :integer
    add_column :core_projects, :organization_department_id, :integer

    add_index :core_projects, :organization_id
    add_index :core_projects, :organization_department_id
  end
end
