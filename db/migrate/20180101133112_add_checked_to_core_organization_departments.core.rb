# This migration comes from core (originally 20180101132337)
class AddCheckedToCoreOrganizationDepartments < ActiveRecord::Migration
  def change
    add_column :core_organization_departments, :checked, :boolean, default: false
  end
end
