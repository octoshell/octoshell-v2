module Core
  class Admin::JobNotificationGlobalDefaultsController < Admin::ApplicationController
    before_action :octo_authorize!
    before_action :set_notification
    before_action :set_global_default

    def edit
    end

    def update
      if @global_default.update(global_default_params)
        redirect_to [:admin, @notification],
                    notice: t('core.admin.job_notification_global_defaults.update.notice')
      else
        render :edit
      end
    end

    private

    def set_notification
      @notification = JobNotification.find(params[:job_notification_id])
    end

    def set_global_default
      @global_default = @notification.global_default
    end

    def global_default_params
      params.require(:job_notification_global_default).permit(
        :notify_tg, :notify_mail, :kill_job
      )
    end
  end
end
