module Core
    class UserNotificationSettingsController < ApplicationController
      before_action :require_login
      before_action :set_user
      before_action :set_user_notification_settings

      def edit
      end

      def update
        if @user_notification_settings.update(user_notification_settings_params)
          redirect_to edit_user_notification_setting_path, notice: 'Настройки уведомлений успешно обновлены.'
        else
          render :edit
        end
      end

      private

      def set_user_notification_settings
        @user_notification_settings = UserNotificationSetting.for_user(current_user)
      end

      def user_notification_settings_params
        params.require(:user_notification_setting).permit(:notification_batch_interval)
      end

      def set_user
        @user = User.find(current_user.id)
      end
    end
  end
