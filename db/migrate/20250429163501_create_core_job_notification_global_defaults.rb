class CreateCoreJobNotificationGlobalDefaults < ActiveRecord::Migration[5.2]
    def change
      create_table :core_job_notification_global_defaults do |t|
        t.belongs_to :core_job_notification, null: false,
                    foreign_key: true,
                    index: { name: 'idx_core_job_notif_global_defaults_notif_id' }
        t.boolean :notify_tg, default: false
        t.boolean :notify_mail, default: false
        t.boolean :kill_job, default: false

        t.timestamps
      end
    end
  end
