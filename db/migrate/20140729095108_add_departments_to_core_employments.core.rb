# This migration comes from core (originally 20140729094902)
class AddDepartmentsToCoreEmployments < ActiveRecord::Migration
  def change
    add_column :core_employments, :organization_department_id, :integer, null: false
    add_index :core_employments, :organization_department_id
  end
end
