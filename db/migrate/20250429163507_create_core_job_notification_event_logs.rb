class CreateCoreJobNotificationEventLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :core_job_notification_event_logs do |t|
      t.belongs_to :user, null: false, foreign_key: true, index: { name: 'idx_job_event_logs_user_id' }
      t.integer :events_count, default: 0
      t.jsonb :summary_data
      t.text :details
      t.datetime :start_period
      t.datetime :end_period

      t.timestamps
    end

    add_index :core_job_notification_event_logs, [:user_id, :start_period], name: 'idx_job_event_logs_user_period'
  end
end
