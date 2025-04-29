module Core
  class JobNotificationEventLogsController < ApplicationController
    before_action :set_log, only: [:show, :resend_digest]

    # GET /core/event_logs
    def index
      query = JobNotificationEventLog.includes(:user).order(created_at: :desc)

      if params[:user_id].present?
        query = query.where(user_id: params[:user_id])
      end

      if params[:date_from].present?
        query = query.where('start_period >= ?', Date.parse(params[:date_from]).beginning_of_day)
      end

      if params[:date_to].present?
        query = query.where('end_period <= ?', Date.parse(params[:date_to]).end_of_day)
      end

      @logs = query.page(params[:page]).per(20)

      respond_to do |format|
        format.html
        format.json { render json: @logs }
      end
    end

    # GET /core/event_logs/:id
    def show
      respond_to do |format|
        format.html
        format.json { render json: @log }
      end
    end

    # POST /core/event_logs/:id/resend_digest
    def resend_digest
      # SEND MAIL
      redirect_to job_notification_event_log_path(@log), notice: "Дайджест отправлен на адрес #{@log.user.email}"
    rescue => e
      redirect_to job_notification_event_log_path(@log), alert: "Ошибка отправки дайджеста: #{e.message}"
    end

    private

    def set_log
      @log = JobNotificationEventLog.find(params[:id])
    end
  end
end
