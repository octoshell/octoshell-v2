class CreateCoreComments < ActiveRecord::Migration[5.2]
  def change
    create_table :core_comments, if_not_exists: true do |t|
      t.references :author, null: false, type: :integer, foreign_key: { to_table: :users }
      t.references :cluster, null: false, type: :integer, foreign_key: { to_table: :core_clusters }, index: true

      t.string :title, null: false
      t.text :body
      t.datetime :valid_from, null: false
      t.datetime :valid_to
      t.integer :severity, null: false, default: 0

      t.integer :reason_group_id
      t.integer :reason_id

      t.timestamps null: false
    end

    add_index :core_comments, [:cluster_id, :valid_from],
              name: "index_core_comments_on_cluster_id_and_valid_from",
              if_not_exists: true

    add_index :core_comments, [:cluster_id, :valid_to],
              name: "index_core_comments_on_cluster_id_and_valid_to",
              if_not_exists: true

    add_index :core_comments, [:cluster_id, :severity],
              name: "index_core_comments_on_cluster_id_and_severity",
              if_not_exists: true

    add_index :core_comments, :cluster_id,
              where: "valid_to IS NULL",
              name: "index_core_comments_current_open_ended_on_cluster_id",
              if_not_exists: true

    add_index :core_comments, :reason_group_id, if_not_exists: true
    add_index :core_comments, :reason_id, if_not_exists: true
    add_index :core_comments, [:reason_group_id, :reason_id], if_not_exists: true
  end
end