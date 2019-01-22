class CreateCoreAccesses < ActiveRecord::Migration
  def change
    create_table :core_accesses do |t|
      t.integer  "project_id", null: false
      t.integer  "cluster_id", null: false
      t.string   "state"
      t.timestamps

      t.index :project_id
      t.index :cluster_id
      t.index [:project_id, :cluster_id], unique: true
    end
  end
end
