module Core
    class JobNotification < ApplicationRecord
      self.table_name = 'core_job_notifications'

      has_one :global_default,
              class_name: 'Core::JobNotificationGlobalDefault',
              foreign_key: 'core_job_notification_id',
              dependent: :destroy

      has_many :user_defaults,
              class_name: 'Core::JobNotificationUserDefault',
              foreign_key: 'core_job_notification_id',
              dependent: :destroy

      has_many :project_settings,
              class_name: 'Core::JobNotificationProjectSetting',
              foreign_key: 'core_job_notification_id',
              dependent: :destroy


      validates :name, presence: true, uniqueness: true
      validates :global_default, presence: true

      after_create :create_global_default

      # Метод для получения настроек пользователя для данного уведомления
      def user_settings(user, project = nil)
        if project
          project_setting = project_settings.find_by(project: project, user: user)
          return project_setting if project_setting.present?
        end

        user_default = user_defaults.find_by(user: user)
        return user_default if user_default.present?

        global_default
      end

      private

      def create_global_default
      end
    end
  end
