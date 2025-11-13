# This migration comes from core (originally 20251113125307)
class CreateJoinTableResourceControlPartition < ActiveRecord::Migration[5.2]
  def change
    create_join_table :core_resource_controls, :core_partitions do |t|
      t.index [:core_resource_control_id, :core_partition_id], unique: true,
      name: 'index_core_partitions_resource_controls'

    end
  end
end
