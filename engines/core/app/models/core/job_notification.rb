module Core
    class JobNotification < ApplicationRecord
      self.table_name = 'core_job_notifications'
      ACTIONS = %i[notify_tg notify_mail kill_job].freeze
      has_one :global_default,
              class_name: 'Core::JobNotificationGlobalDefault',
              foreign_key: 'core_job_notification_id',
              dependent: :destroy, inverse_of: :job_notification

      has_many :user_defaults,
              class_name: 'Core::JobNotificationUserDefault',
              foreign_key: 'core_job_notification_id',
              dependent: :destroy, inverse_of: :job_notification

      has_many :project_settings,
              class_name: 'Core::JobNotificationProjectSetting',
              foreign_key: 'core_job_notification_id',
              dependent: :destroy,  inverse_of: :job_notification


      validates :name, presence: true, uniqueness: true
      validates :global_default, presence: true
      before_validation :create_global_default, on: :create

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
        global_default || build_global_default(notify_tg: false, notify_mail: false, kill_job: false)
      end
    end
  end
