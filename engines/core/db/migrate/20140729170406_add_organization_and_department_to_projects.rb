class AddOrganizationAndDepartmentToProjects < ActiveRecord::Migration
  def change
    add_column :core_projects, :organization_id, :integer
    add_column :core_projects, :organization_department_id, :integer

    add_index :core_projects, :organization_id
    add_index :core_projects, :organization_department_id
  end
end
