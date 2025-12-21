# This migration comes from core (originally 20251125110939)
class AddJobLimitsToCorePartitions < ActiveRecord::Migration[5.2]
  def change
    add_column :core_partitions, :max_running_jobs, :integer
    add_column :core_partitions, :max_submitted_jobs, :integer
  end
end
