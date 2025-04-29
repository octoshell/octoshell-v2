module Core
  class ProjectsUsersJobNotificationsController < ApplicationController
      before_action :require_login

      before_action :set_project
      before_action :set_user

      def index
        @notifications = Core::JobNotification.all
        @project_settings = @project.job_notification_project_settings
                                  .where(user: @user)
                                  .includes(:job_notification)
                                  .index_by(&:core_job_notification_id)

        @user_defaults = @user.job_notification_user_defaults
                              .includes(:job_notification)
                              .index_by(&:core_job_notification_id)
      end

      private

      def set_project
        @project = Project.find(params[:project_id])
      end

      def set_user
        @user = User.find(current_user.id)
      end
    end
  end
