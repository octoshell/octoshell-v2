class CreateCoreQueueAccesses < ActiveRecord::Migration[5.2]
  def change
    create_table :core_queue_accesses do |t|
      t.belongs_to :access
      t.belongs_to :partition
      t.belongs_to :resource_control
      t.boolean :synced_with_cluster, default: false
      t.string :status, null: false
      t.integer :max_running_jobs
      t.integer :max_submitted_jobs
      t.timestamps
    end
  end
end
