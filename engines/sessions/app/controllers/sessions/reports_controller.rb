module Sessions
  class ReportsController < Sessions::ApplicationController
    layout 'layouts/sessions/user'

    def index
      @search = current_user.reports.ransack(params[:q] || default_index_params)
      @reports = @search.result(distinct: true).page(params[:page])
    end

    def accept
      @report = get_report(params[:report_id])
      @report.accepted? || @report.accept!
      @report.save
      redirect_to @report
    end

    def decline_submitting
      @report = get_report(params[:report_id])
      render :edit
    end

    def update
      @report = get_report(params[:id])
      unless @report.may_decline_submitting?
        redirect_to(reports_path)
        return
      end
      @report.decline_submitting
      if @report.update(report_params)
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
      @reply = @report.replies.build(reply_params) do |reply|
        reply.user = current_user
      end
      @reply.save
      redirect_to @report
    end

    def submit
      @report = get_report(params[:report_id])
      if params[:report].nil? || report_params[:report_material].empty?
        redirect_to @report, alert: t('flash.you_must_provide_report_materials')
        return
      end
      begin
        if @report.update(report_params)
          if @report.rejected?
            @report.resubmit!
          elsif @report.may_submit?
            @report.submit!
          end
          redirect_to @report
        else
          @reply = @report.replies.build do |reply|
            reply.user = current_user
          end
          render :show
        end
      rescue CarrierWave::IntegrityError => e
        redirect_to @report, alert: e.message
      end
    end

    private

    def default_index_params
      if s = Session.current
        params[:session_id_in] = s.id
      end
      params
    end

    def get_report(id)
      current_user.reports.find(id)
    end

    def reply_params
      params.require(:report_reply).permit(:message)
    end

    def report_params
      params.require(:report).permit(:submit_denial_reason_id,
                                     :submit_denial_description,
                                     :materials, report_material: %i[materials id])
    end
  end
end
