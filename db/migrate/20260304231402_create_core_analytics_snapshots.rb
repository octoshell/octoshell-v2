class CreateCoreAnalyticsSnapshots < ActiveRecord::Migration[5.2]
  def change
    create_table :core_analytics_snapshots, if_not_exists: true do |t|
      t.references :cluster, null: false, foreign_key: { to_table: :core_clusters }, index: true
      t.datetime :captured_at, null: false
      t.string :source_cmd, null: false
      t.string :parser_version, null: false
      t.text :raw_text, null: false
      t.timestamps null: false
    end

    add_index :core_analytics_snapshots, [:cluster_id, :captured_at],
              name: "index_core_analytics_snapshots_on_cluster_id_and_captured_at",
              if_not_exists: true
  end
end