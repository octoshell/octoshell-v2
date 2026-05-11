class CreateCoreAnalyticsNodeStates < ActiveRecord::Migration[5.2]
  def change
    create_table :core_analytics_node_states, if_not_exists: true do |t|
      t.references :cluster, null: false, foreign_key: { to_table: :core_clusters }, index: true
      t.references :snapshot, null: false, foreign_key: { to_table: :core_analytics_snapshots }, index: true
      t.references :node, null: false, foreign_key: { to_table: :core_analytics_nodes }, index: true
      t.references :partition, null: false, foreign_key: { to_table: :core_partitions }, index: true

      t.string  :state, null: false
      t.string  :substate
      t.boolean :has_reason, null: false, default: false
      t.datetime :valid_from, null: false
      t.datetime :valid_to
      t.timestamps null: false
    end

    add_index :core_analytics_node_states, [:snapshot_id, :node_id, :partition_id],
              unique: true,
              name: "core_analytics_uniq_node_partition_per_snapshot",
              if_not_exists: true

    add_index :core_analytics_node_states, [:node_id, :valid_from],
              name: "core_analytics_index_node_states_on_node_id_and_valid_from",
              if_not_exists: true

    add_index :core_analytics_node_states, [:node_id, :valid_to],
              name: "core_analytics_index_node_states_on_node_id_and_valid_to",
              if_not_exists: true

    add_index :core_analytics_node_states, :node_id,
              where: "valid_to IS NULL",
              name: "core_analytics_index_node_states_current_on_node_id",
              if_not_exists: true
  end
end