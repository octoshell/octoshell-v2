class CreateCoreCommentsNodes < ActiveRecord::Migration[5.2]
  def change
    create_table :core_comments_nodes, if_not_exists: true do |t|
      t.references :comment, null: false, index: true, foreign_key: { to_table: :core_comments }
      t.references :node, null: false, index: true, foreign_key: { to_table: :core_analytics_nodes }
      t.timestamps null: false
    end

    add_index :core_comments_nodes, [:comment_id, :node_id],
              unique: true,
              name: "index_core_comments_nodes_unique_comment_node",
              if_not_exists: true
  end
end