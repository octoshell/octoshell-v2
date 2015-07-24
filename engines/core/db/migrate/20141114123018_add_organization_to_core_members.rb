class AddOrganizationToCoreMembers < ActiveRecord::Migration
  def change
    add_column :core_members, :organization_id, :integer
    add_column :core_members, :organization_department_id, :integer

    add_index :core_members, :organization_id
  end
end
