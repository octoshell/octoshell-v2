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
          settings[field] = settings_object.get_setting(field)
        end

        settings
      end

      def update_user_default_settings(notification, user, settings)
        user_default = notification.user_defaults.find_or_initialize_by(user: user)

        [:notify_tg, :notify_mail, :kill_job].each do |field|
          user_default[field] = settings[field] if settings.key?(field)
        end

        user_default.save
        user_default
      end

      def update_project_settings(notification, user, project, settings)
        project_setting = notification.project_settings.find_or_initialize_by(
          user: user,
          project: project
        )

        [:notify_tg, :notify_mail, :kill_job].each do |field|
          project_setting[field] = settings[field] if settings.key?(field)
        end

        project_setting.save
        project_setting
      end

      def update_global_default_settings(notification, settings)
        global_default = notification.global_default

        [:notify_tg, :notify_mail, :kill_job].each do |field|
          global_default[field] = settings[field] if settings.key?(field)
        end

        global_default.save
        global_default
      end

      def delete_user_default_settings(notification, user)
        user_default = notification.user_defaults.find_by(user: user)
        return false unless user_default

        user_default.destroy
        true
      end

      def delete_project_settings(notification, user, project)
        project_setting = notification.project_settings.find_by(
          user: user,
          project: project
        )
        return false unless project_setting

        project_setting.destroy
        true
      end
    end
  end
