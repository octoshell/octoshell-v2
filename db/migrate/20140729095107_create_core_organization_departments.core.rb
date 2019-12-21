# This migration comes from core (originally 20140729093405)
class CreateCoreOrganizationDepartments < ActiveRecord::Migration[4.2]
  def change
    create_table :core_organization_departments do |t|
      t.integer :organization_id
      t.string :name

      t.index :organization_id
    end
  end
end
