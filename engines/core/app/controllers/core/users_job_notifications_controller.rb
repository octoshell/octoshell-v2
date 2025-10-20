module Core
  class UsersJobNotificationsController < ApplicationController
      before_action :require_login
      before_action :set_user
      layout 'layouts/core/events'
      def index
        @notifications = Core::JobNotification.includes(:global_default).all
        @user_defaults = @user.job_notification_user_defaults.includes(:job_notification)
                              .index_by(&:core_job_notification_id)
      end

      private

      def set_user
        @user = current_user
      end
    end
  end
