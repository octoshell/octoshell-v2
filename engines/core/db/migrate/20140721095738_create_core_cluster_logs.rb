class CreateCoreClusterLogs < ActiveRecord::Migration
  def change
    create_table :core_cluster_logs do |t|
      t.integer  "cluster_id", null: false
      t.text     "message",    null: false
      t.timestamps

      t.index :cluster_id
    end
  end
end
