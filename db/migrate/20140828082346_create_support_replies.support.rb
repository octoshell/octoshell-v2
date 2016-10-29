# This migration comes from support (originally 20140827145710)
class CreateSupportReplies < ActiveRecord::Migration
  def change
    create_table :support_replies do |t|
      t.integer :author_id
      t.integer :ticket_id

      t.text :message
      t.string :attachment

      t.timestamps

      t.index :author_id
      t.index :ticket_id
    end
  end
end
