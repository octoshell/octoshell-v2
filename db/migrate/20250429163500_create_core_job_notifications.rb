class CreateCoreJobNotifications < ActiveRecord::Migration[5.2]
    def change
      create_table :core_job_notifications do |t|
        t.string :name, null: false
        t.text :description

        t.timestamps
      end

      add_index :core_job_notifications, :name, unique: true, name: 'idx_core_job_notif_name_uniq'
    end
  end
