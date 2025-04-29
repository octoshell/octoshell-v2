module Core
    class JobNotificationProjectSettingsController < ApplicationController
      before_action :set_project
      before_action :set_user
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
                      notice: 'Настройки уведомления для проекта успешно созданы.'
        else
          render :new
        end
      end

      def edit
      end

      def update
        if @project_setting.update(project_setting_params)
          redirect_to projects_users_job_notifications_path(@project, @user),
                      notice: 'Настройки уведомления для проекта успешно обновлены.'
        else
          render :edit
        end
      end

      def destroy
        @project_setting.destroy
        redirect_to projects_users_job_notifications_path(@project, @user),
                    notice: 'Настройки уведомления для проекта успешно удалены.'
      end

      private

      def set_project
        logger.warn "PARAMS: #{params}"
        @project = Project.find(params[:project_id])
      end

      def set_user
        @user = User.find(params[:user_id])
      end

      def set_notification
        @notification = JobNotification.find(params[:job_notification_id])
      end

      def set_project_setting
        @project_setting = JobNotificationProjectSetting.find_by(
          core_job_notification_id: @notification.id,
          core_project_id: @project.id,
          user: @user
        )

        unless @project_setting
          redirect_to projects_users_job_notifications_path(@project, @user),
                      alert: 'Настройки уведомления для проекта не найдены.'
        end
      end

      def project_setting_params
        permitted_params = params.require(:job_notification_project_setting).permit(
          :notify_tg, :notify_mail, :kill_job
        )

        permitted_params
      end
    end
  end
