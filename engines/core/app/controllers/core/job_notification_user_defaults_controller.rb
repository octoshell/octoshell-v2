module Core
    class JobNotificationUserDefaultsController < ApplicationController
      before_action :require_login

      before_action :set_user
      before_action :set_notification
      before_action :set_user_default, only: [:edit, :update, :destroy]

      def new
        @user_default = JobNotificationUserDefault.new(
          user: @user,
          core_job_notification_id: @notification
        )
      end

      def create
        @user_default = JobNotificationUserDefault.new(user_default_params)
        @user_default.user = @user
        @user_default.job_notification = @notification

        if @user_default.save
          redirect_to users_job_notifications_path(@user),
                      notice: 'Пользовательские настройки уведомления успешно созданы.'
        else
          render :new
        end
      end

      def edit
      end

      def update
        if @user_default.update(user_default_params)
          redirect_to users_job_notifications_path(@user),
                      notice: 'Пользовательские настройки уведомления успешно обновлены.'
        else
          render :edit
        end
      end

      def destroy
        @user_default.destroy
        redirect_to users_job_notifications_path(@user),
                    notice: 'Пользовательские настройки уведомления успешно удалены.'
      end

      private

      def set_user
        @user = User.find(current_user.id)
      end

      def set_notification
        @notification = JobNotification.find(params[:job_notification_id])
      end

      def set_user_default
        @user_default = JobNotificationUserDefault.find_by(
          user: @user,
          core_job_notification_id: @notification.id
        )

        unless @user_default
          redirect_to users_job_notifications_path(@user),
                      alert: 'Пользовательские настройки уведомления не найдены.'
        end
      end

      def user_default_params
        permitted_params = params.require(:job_notification_user_default).permit(
          :notify_tg, :notify_mail, :kill_job
        )

        permitted_params
      end
    end
  end
