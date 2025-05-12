module Core
  class JobNotificationProjectSettingsController < ApplicationController
    before_action :require_login

    before_action :set_project
    before_action :set_user
    before_action :check_user_in_project
    before_action :set_notification
    before_action :set_project_setting, only: [:edit, :update, :destroy]

    def new
      @project_setting = JobNotificationProjectSetting.new(
        core_job_notification_id: @notification.id,
        core_project_id: @project.id,
        user: @user
      )
    end

    def create
      @project_setting = JobNotificationProjectSetting.new(project_setting_params)
      @project_setting.core_project_id = @project.id
      @project_setting.core_job_notification_id = @notification.id
      @project_setting.user = @user

      if @project_setting.save
        redirect_to projects_users_job_notifications_path(@project, @user),
                    notice: t('core.job_notification_project_settings.create.notice')
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @project_setting.update(project_setting_params)
        redirect_to projects_users_job_notifications_path(@project, @user),
                    notice: t('core.job_notification_project_settings.update.notice')
      else
        render :edit
      end
    end

    def destroy
      @project_setting.destroy
      redirect_to projects_users_job_notifications_path(@project, @user),
                  notice: t('core.job_notification_project_settings.destroy.notice')
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
        redirect_to users_job_notifications_path(@user), alert: t('core.job_notification_project_settings.check_user_in_project.alert')
        return
      end
    end

    def set_notification
      @notification = JobNotification.find(params[:job_notification_id])
    end

    def set_project_setting
      @project_setting = JobNotificationProjectSetting.find_by(
        id: params[:id]
      )

      unless @project_setting
        redirect_to projects_users_job_notifications_path(@project, @user),
                    alert: t('core.job_notification_project_settings.set_project_setting.alert')
      end
    end

    def project_setting_params
      permitted_params = params.require(:job_notification_project_setting).permit(
        :notify_tg, :notify_mail, :kill_job
      )

      %w(notify_tg notify_mail kill_job).each do |attr|
        permitted_params[attr] = nil if permitted_params[attr] == "on"
      end

      permitted_params
    end
  end
end
