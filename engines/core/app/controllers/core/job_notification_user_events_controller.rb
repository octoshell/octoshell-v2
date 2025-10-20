module Core
  class JobNotificationUserEventsController < ApplicationController
    before_action :require_login
    layout 'layouts/core/events'
    def index
      @search = JobNotificationEvent.search(params[:q] ||
                                            { created_at_gt: Date.current - 7.days })
      common_relation = @search.result(distinct: true).where(user: current_user)
      @events = common_relation.order(id: :desc)
      .includes(:job_notification, :core_project)
                       .page(params[:page]).per(15)
      @event_stats = common_relation.group('core_job_notification_id')
                                    .select('COUNT(id), core_job_notification_id')
                                    .includes(:job_notification)
                                    .sort_by { |r| - r['count'] }
                                    .to_a
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
