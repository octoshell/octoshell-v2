module Core
  class Admin::UserJobNotificationsController < Admin::ApplicationController
    before_action :octo_authorize!
    before_action :set_user

    def index
      @notifications = Core::JobNotification.includes(:global_default).all
      @user_defaults = @user.job_notification_user_defaults.includes(:job_notification)
                            .index_by(&:core_job_notification_id)
    end

    private

    def set_user
      @user = User.find(params[:user_id])
    end
  end
end
