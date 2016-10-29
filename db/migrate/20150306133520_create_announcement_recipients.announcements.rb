# This migration comes from announcements (originally 20150306132616)
class CreateAnnouncementRecipients < ActiveRecord::Migration
  def change
    create_table :announcement_recipients do |t|
      t.integer :user_id
      t.integer :announcement_id

      t.index :user_id
      t.index :announcement_id
    end
  end
end
