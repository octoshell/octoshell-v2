module Core
    class JobNotificationProjectSetting < ApplicationRecord
      self.table_name = 'core_job_notification_project_settings'

      belongs_to :job_notification,
                class_name: 'Core::JobNotification',
                foreign_key: 'core_job_notification_id', inverse_of: :project_settings

      belongs_to :project,
                class_name: 'Core::Project',
                foreign_key: 'core_project_id'

      belongs_to :user

      validates :core_job_notification_id, uniqueness: { scope: [:core_project_id, :user_id] }

    end
  end
