# This migration comes from core (originally 20140721095316)
class CreateCoreRequests < ActiveRecord::Migration
  def change
    create_table :core_requests do |t|
      t.integer  "project_id", null: false
      t.integer  "cluster_id", null: false
      t.string   "state"
      t.timestamps

      t.index :project_id
      t.index :cluster_id
    end
  end
end
