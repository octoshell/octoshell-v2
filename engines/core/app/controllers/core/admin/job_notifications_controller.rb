require 'json'

module Core
    class Admin::JobNotificationsController < Admin::ApplicationController
      before_action :octo_authorize!
      before_action :set_notification, only: [:show, :edit, :update, :destroy]

      def index
        @notifications = JobNotification.all
      end

      def show
      end

      def new
        @notification = JobNotification.new
        @notification.global_default = JobNotificationGlobalDefault.new
      end

      def create
        @notification = JobNotification.new(notification_params)
        @notification.build_global_default(notify_tg: false, notify_mail: false, kill_job: false)

        if @notification.save
          redirect_to [:admin, @notification], notice: 'Уведомление задачи успешно создано.'
        else
          render :new
        end
      end

      def edit
      end

      def update
        if @notification.update(notification_params)
          redirect_to [:admin, @notification], notice: 'Уведомление задачи успешно обновлено.'
        else
          render :edit
        end
      end

      def destroy
        @notification.destroy
        redirect_to "/core/admin/job_notifications", notice: 'Уведомление задачи успешно удалено.'
      end

      def update_from_json
        file_path = Rails.root.join('engines', 'jobstat', 'config', 'conditions.json')
        json_data = JSON.parse(File.read(file_path))

        json_data['rules'].each do |key, rule|
          notification = JobNotification.find_or_initialize_by(name: rule['name'])
          notification.description = rule['description']
          notification.build_global_default(notify_tg: false, notify_mail: false, kill_job: false)

          notification.save
        end

        redirect_to admin_job_notifications_path, notice: 'Уведомления обновлены из JSON файла.'
      rescue StandardError => e
        redirect_to admin_job_notifications_path, alert: "Ошибка при обновлении из JSON: #{e.message}"
      end

      private

      def set_notification
        @notification = JobNotification.find(params[:id])
      end

      def notification_params
        params.require(:job_notification).permit(:name, :description)
      end
    end
  end
