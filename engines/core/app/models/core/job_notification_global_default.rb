module Core
    class JobNotificationGlobalDefault < ApplicationRecord
      self.table_name = 'core_job_notification_global_defaults'

      belongs_to :job_notification,
                class_name: 'Core::JobNotification',
                foreign_key: 'core_job_notification_id',  inverse_of: :global_default

      validates :core_job_notification_id, presence: true, uniqueness: true

    end
  end
