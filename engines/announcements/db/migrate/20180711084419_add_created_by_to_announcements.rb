class AddCreatedByToAnnouncements < ActiveRecord::Migration
  def change
     add_column :announcements, :created_by_id, :integer
     add_index :announcements, :created_by_id
  end
end
