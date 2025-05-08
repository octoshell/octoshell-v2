class CreateCoreUserNotificationSettings < ActiveRecord::Migration[5.2]
  def change
    create_table :core_user_notification_settings do |t|
      t.belongs_to :user, null: false, foreign_key: true, index: { unique: true, name: 'idx_core_user_notification_settings_user' }
      t.integer :notification_batch_interval, default: 5 # интервал в минутах

      t.timestamps
    end
  end
end
