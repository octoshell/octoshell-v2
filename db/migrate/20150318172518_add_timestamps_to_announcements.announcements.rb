# This migration comes from announcements (originally 20150318172430)
class AddTimestampsToAnnouncements < ActiveRecord::Migration
  def change
    add_timestamps :announcements
  end
end
