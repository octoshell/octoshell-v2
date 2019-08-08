# This migration comes from announcements (originally 20150306132309)
class CreateAnnouncements < ActiveRecord::Migration[4.2]
  def change
    create_table :announcements do |t|
      t.string :title
      t.string :reply_to
      t.text :body
      t.string :attachment
      t.boolean :is_special
      t.string :state
    end
  end
end
