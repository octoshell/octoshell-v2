# This migration comes from core (originally 20260308100244)
class CreateCoreResourceControlPartitions < ActiveRecord::Migration[7.2]
  def change
    create_table :core_resource_control_partitions do |t|
      t.belongs_to :partition
      t.belongs_to :resource_control
      t.integer :max_running_jobs
      t.integer :max_submitted_jobs
      t.timestamps
    end
  end
end
