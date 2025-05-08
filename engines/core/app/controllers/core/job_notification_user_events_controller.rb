module Core
  class JobNotificationUserEventsController < ApplicationController
    before_action :require_login

    def index
      @events = JobNotificationEvent.includes(:job_notification, :core_project)
                                   .where(user: current_user)
                                   .order(created_at: :desc)
                                   .page(params[:page]).per(15)

      respond_to do |format|
        format.html
        format.json { render json: @events }
      end
    end

    def show
      @event = JobNotificationEvent.find(params[:id])

      if @event.user_id != current_user.id
        redirect_to user_events_path, alert: t('user_events.unauthorized')
        return
      end

      respond_to do |format|
        format.html
        format.json { render json: @event }
      end
    end

    private

    def set_user
      @user = current_user
    end
  end
end
