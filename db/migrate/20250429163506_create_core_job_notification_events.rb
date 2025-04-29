class CreateCoreJobNotificationEvents < ActiveRecord::Migration[5.2]
    def change
      create_table :core_job_notification_events do |t|
        t.belongs_to :core_job_notification, null: false, foreign_key: true, index: { name: 'idx_job_events_notification_id' }
        t.belongs_to :perf_job, null: false, index: { name: 'idx_job_events_job_id' }
        t.belongs_to :user, null: false, foreign_key: true
        t.belongs_to :core_project, null: false, foreign_key: true
        t.jsonb :data, default: {}
        t.boolean :processed, default: false
        t.string :status, default: "unprocessed"
        t.datetime :processed_at

        t.timestamps
      end

      add_index :core_job_notification_events, :processed, name: 'idx_job_events_processed'
    end
  end
