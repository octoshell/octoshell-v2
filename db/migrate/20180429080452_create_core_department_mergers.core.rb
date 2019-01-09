# This migration comes from core (originally 20180429075123)
class CreateCoreDepartmentMergers < ActiveRecord::Migration
  def change
    create_table :core_department_mergers do |t|
      t.integer :source_department_id
      t.integer :to_organization_id
      t.integer :to_department_id
      t.timestamps null: false
    end
  end
end
