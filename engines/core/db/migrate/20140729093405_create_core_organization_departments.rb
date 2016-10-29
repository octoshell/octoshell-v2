class CreateCoreOrganizationDepartments < ActiveRecord::Migration
  def change
    create_table :core_organization_departments do |t|
      t.integer :organization_id
      t.string :name

      t.index :organization_id
    end
  end
end
