# This migration comes from comments (originally 20170801160707)
class CreateCommentsComments < ActiveRecord::Migration
  def change
    # drop_table :comments_comments
    # drop_table :comments_contexts
    # drop_table :comments_context_groups
    # drop_table :comments_group_classes
    # drop_table :comments_tags
    # drop_table :comments_taggings
    # drop_table :comments_file_attachments
    create_table :comments_comments do |t|
   	  t.text :text
   	  t.belongs_to :attachable,{index: true,null: false,polymorphic: true}
   	  t.belongs_to :user,{index: true,null: false}
      t.belongs_to :context,{index: true}
      t.timestamps null: false
    end
  end
end
