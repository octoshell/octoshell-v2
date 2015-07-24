module Sessions
  class ReportsController < ApplicationController
    layout "layouts/sessions/user"

    def index
      @search = current_user.reports.search(params[:q] || default_index_params)
      @reports = @search.result(distinct: true).page(params[:page])
    end

    def accept
      @report = get_report(params[:report_id])
      @report.accepted? || @report.accept!
      redirect_to @report
    end

    def decline_submitting
      @report = get_report(params[:report_id])
      @report.can_not_be_submitted? || @report.decline_submitting!
      render :edit
    end

    def edit
      @report = get_report(params[:id])
    end

    def update
      @report = get_report(params[:id])
      if @report.update(report_params[:report])
        redirect_to reports_path
      else
        render :edit, alert: @report.errors.full_messages
      end
    end

    def show
      @report = get_report(params[:id])
      @reply = @report.replies.build do |reply|
        reply.user = current_user
      end
    end

    def replies
      @report = get_report(params[:report_id])
      @reply = @report.replies.build(report_params[:report_reply]) do |reply|
        reply.user = current_user
      end
      @reply.save
      redirect_to @report
    end

    def submit
      @report = get_report(params[:report_id])
      if report_params[:report].present? && report_params[:report][:materials].present?
        @report.update(report_params[:report])
        @report.submit! unless @report.submitted?
        redirect_to @report
      else
        redirect_to @report, alert: t("flash.you_must_provide_report_materials")
      end
    end

    def resubmit
      @report = get_report(params[:report_id])
      if report_params[:report].present? && report_params[:report][:materials].present?
        @report.update(report_params[:report])
        @report.resubmit if @report.rejected?
        redirect_to @report
      else
        redirect_to @report, alert: t("flash.you_must_provide_report_materials")
      end
    end

    private

    def default_index_params
      if s = Session.current
        params[:session_id_eq] = s.id
      end
      params
    end

    def get_report(id)
      current_user.reports.find(id)
    end

    def report_params
      params.permit(report: [ :submit_denial_reason_id,
                              :submit_denial_description,
                              :materials ],
                    report_reply: [ :message ])
    end
  end
end
