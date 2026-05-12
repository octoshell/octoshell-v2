class CreateCoreAnalyticsNodes < ActiveRecord::Migration[5.2]
  def change
    create_table :core_analytics_nodes, if_not_exists: true do |t|
      t.references :cluster, null: false, foreign_key: { to_table: :core_clusters }, index: true
      t.string :hostname, null: false
      t.string :prefix, null: false
      t.timestamps null: false
    end

    add_index :core_analytics_nodes, [:cluster_id, :hostname],
              unique: true,
              name: "index_core_analytics_nodes_on_cluster_id_and_hostname",
              if_not_exists: true
  end
end