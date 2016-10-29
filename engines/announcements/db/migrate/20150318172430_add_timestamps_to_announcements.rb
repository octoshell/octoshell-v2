class AddTimestampsToAnnouncements < ActiveRecord::Migration
  def change
    add_timestamps :announcements
  end
end
