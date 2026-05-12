class CreateCoreCommentTags < ActiveRecord::Migration[5.2]
  def change
    create_table :core_comment_tags, id: false, if_not_exists: true do |t|
      t.references :comment, null: false, index: false, foreign_key: { to_table: :core_comments }
      t.references :tag, null: false, index: false, foreign_key: { to_table: :core_tags }
      t.datetime :created_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
    end

    add_index :core_comment_tags, [:comment_id, :tag_id],
              unique: true,
              name: "index_core_comment_tags_unique_comment_tag",
              if_not_exists: true

    add_index :core_comment_tags, :tag_id,
              name: "index_core_comment_tags_on_tag_id",
              if_not_exists: true
  end
end