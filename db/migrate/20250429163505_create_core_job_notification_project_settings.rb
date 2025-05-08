class CreateCoreJobNotificationProjectSettings < ActiveRecord::Migration[5.2]
    def change
      create_table :core_job_notification_project_settings do |t|
        t.belongs_to :core_job_notification, null: false,
                    foreign_key: true,
                    index: { name: 'idx_core_job_proj_settings_notif_id' }
        t.belongs_to :core_project, null: false, foreign_key: true
        t.belongs_to :user, null: false, foreign_key: true
        t.boolean :notify_tg
        t.boolean :notify_mail
        t.boolean :kill_job

        t.timestamps
      end

      add_index :core_job_notification_project_settings,
                [:core_job_notification_id, :core_project_id, :user_id],
                unique: true,
                name: 'idx_core_job_proj_settings_notif_proj_user_uniq'
    end
  end
