class CreateCoreOrganizationKinds < ActiveRecord::Migration
  def change
    create_table :core_organization_kinds do |t|
      t.string :name
      t.boolean :departments_required, default: false
      t.timestamps
    end
  end
end
