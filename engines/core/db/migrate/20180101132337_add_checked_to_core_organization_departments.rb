class AddCheckedToCoreOrganizationDepartments < ActiveRecord::Migration
  def change
    add_column :core_organization_departments, :checked, :boolean, default: false
  end
end
