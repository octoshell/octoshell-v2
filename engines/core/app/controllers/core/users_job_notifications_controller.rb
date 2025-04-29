module Core
  class UsersJobNotificationsController < ApplicationController
      before_action :require_login
      before_action :set_user

      def index
        @notifications = Core::JobNotification.all
        @user_defaults = @user.job_notification_user_defaults.includes(:job_notification)
                              .index_by(&:core_job_notification_id)
      end

      private

      def set_user
        @user = User.find(current_user.id)
      end
    end
  end
