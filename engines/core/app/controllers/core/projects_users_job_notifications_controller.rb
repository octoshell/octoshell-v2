module Core
  class ProjectsUsersJobNotificationsController < ApplicationController
    before_action :require_login

    before_action :set_project
    before_action :set_user
    before_action :check_user_in_project
    def index
      @notifications = Core::JobNotification.includes(:global_default).all
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
      @user = current_user
    end

    def check_user_in_project
      unless @project.users.exists?(id: @user.id)
        redirect_to users_job_notifications_path(@user), alert: t('core.projects_users_job_notifications.check_user_in_project.alert')
      end
    end
  end
end
