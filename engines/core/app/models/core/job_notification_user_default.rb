module Core
    class JobNotificationUserDefault < ApplicationRecord
      self.table_name = 'core_job_notification_user_defaults'

      belongs_to :job_notification,
                class_name: 'Core::JobNotification',
                foreign_key: 'core_job_notification_id'

      belongs_to :user

      validates :core_job_notification_id, uniqueness: { scope: :user_id }
    end
  end
