module Core
    module JobNotificationSettingsHelper
      def self.get_notification_settings(notification, user, project = nil)
        settings = {}

        settings_object = if project
                            project_setting = notification.project_settings.find_by(
                              project: project,
                              user: user
                            )

                            if project_setting
                              project_setting
                            else
                              user_default = notification.user_defaults.find_by(user: user)
                              user_default || notification.global_default
                            end
                          else
                            user_default = notification.user_defaults.find_by(user: user)
                            user_default || notification.global_default
                          end

        [:notify_tg, :notify_mail, :kill_job].each do |field|
          settings[field] = settings_object[field]
        end

        settings
      end
    end
  end
