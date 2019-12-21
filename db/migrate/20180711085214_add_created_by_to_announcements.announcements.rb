# This migration comes from announcements (originally 20180711084419)
class AddCreatedByToAnnouncements < ActiveRecord::Migration[4.2]
  def change
     add_column :announcements, :created_by_id, :integer
     add_index :announcements, :created_by_id
  end
end
