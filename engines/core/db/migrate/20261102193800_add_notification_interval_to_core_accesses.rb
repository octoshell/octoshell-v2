class AddNotificationIntervalToCoreAccesses < ActiveRecord::Migration[7.2]
  def change
    add_column :core_accesses, :notification_interval_days, :integer, default: 7, null: false
    add_column :core_accesses, :last_notification_at, :datetime
  end
end
