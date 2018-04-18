class CreateCommentsFiles < ActiveRecord::Migration
  def change
    create_table :comments_file_attachments do |t|
      t.string :file
      t.text :description
   	  t.belongs_to :attachable,{index: false,null: false,polymorphic: true}
   	  t.belongs_to :user,{index: true,null: false}
      t.belongs_to :context,{index: true}
      t.timestamps null: false
    end
    add_index :comments_file_attachments, ["attachable_id", "attachable_type"],:name => 'attach_index'
  end
end
