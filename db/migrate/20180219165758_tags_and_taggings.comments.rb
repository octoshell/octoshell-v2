# This migration comes from comments (originally 20180204212307)
class TagsAndTaggings < ActiveRecord::Migration
  def self.up
    create_table :comments_tags do |t|
      t.string :name
    end

    create_table :comments_taggings do |t|
      t.belongs_to :tag
      t.belongs_to :attachable,{index: true,null: false,polymorphic: true}
      t.belongs_to :user,{index: true,null: false}
      t.belongs_to :context,{index: true}
      t.belongs_to :user
      t.timestamps null: false
    end
    add_index :comments_taggings, [:tag_id,:attachable_id, :attachable_type,
                                   :context_id],:unique => true, :name => 'att_contex_index'
  end
end
