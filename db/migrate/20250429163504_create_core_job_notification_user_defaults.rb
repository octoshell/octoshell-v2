class CreateCoreJobNotificationUserDefaults < ActiveRecord::Migration[5.2]
    def change
      create_table :core_job_notification_user_defaults do |t|
        t.belongs_to :core_job_notification, null: false,
                    foreign_key: true,
                    index: { name: 'idx_core_job_user_defaults_notif_id' }
        t.belongs_to :user, null: false, foreign_key: true
        t.boolean :notify_tg
        t.boolean :notify_mail
        t.boolean :kill_job

        t.timestamps
      end

      add_index :core_job_notification_user_defaults,
                [:core_job_notification_id, :user_id],
                unique: true,
                name: 'idx_core_job_user_defaults_notif_user_uniq'
    end
  end
