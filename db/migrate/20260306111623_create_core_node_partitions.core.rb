# frozen_string_literal: true

# This migration comes from core (originally 20260305140000)
class CreateCoreNodePartitions < ActiveRecord::Migration[8.0]
  def change
    create_table :core_node_partitions do |t|
      t.references :node, null: false, foreign_key: { to_table: :core_nodes }
      t.references :partition, null: false, foreign_key: { to_table: :core_partitions }
      t.timestamps
    end

    add_index :core_node_partitions, %i[node_id partition_id], unique: true
  end
end
