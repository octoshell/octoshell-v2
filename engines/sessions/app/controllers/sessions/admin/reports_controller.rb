module Sessions
  class Admin::ReportsController < Admin::ApplicationController
    before_filter { authorize! :manage, :reports }

    def index
      @search = Report.search(params[:q] || default_index_params)
      @reports = if (User.superadmins | User.reregistrators).include? current_user
                   @search.result(distinct: true).page(params[:page])
                 elsif User.experts.include? current_user
                   @search.result(distinct: true).
                     where(expert_id: [nil, current_user.id]).
                     page(params[:page])
                 end
    end

    def edit
      @report = Report.find(params[:report_id])
      @report.edit
      redirect_to [:admin, @report]
    end

    def pick
      @report = Report.find(params[:report_id])

      @report.expert = current_user
      if @report.assessing? || @report.pick!
        redirect_to [:admin, @report]
      else
        redirect_to admin_reports_path(q: { state_in: 'submitted' }),
          alert: @report.errors.full_messages.to_sentence
      end
    end

    def change_expert
      @report = Report.find(params[:report_id])
      @report.assign_attributes(report_params[:report])
      @report.pick!

      redirect_to [:admin, @report]
    end

    def assess
      @report = Report.find(params[:report_id])
      if current_user == @report.expert
        @report.assign_attributes(report_params[:report])
        @report.assess!
        redirect_to [:admin, @report]
      elsif @report.expert.nil? && Sessions.user_class.experts.include?(current_user)
        @report.expert = current_user
        @report.pick!
        @report.assign_attributes(report_params)
        @report.assess!
        redirect_to [:admin, @report]
      else
        raise MayMay::Unauthorized
      end
    end

    def show
      @report = Report.find(params[:id])
      @reply = @report.replies.build do |reply|
        reply.user = current_user
      end
      @reports_for_other_sessions = Report.where(project_id: @report.project_id,
                                                 session_id: Session.where.not(id: @report.session_id))
    end

    def replies
      @report = Report.find(params[:report_id])
      @reply = @report.replies.build(report_params[:report_reply]) do |reply|
        reply.user = current_user
      end
      @reply.save!

      redirect_to [:admin, @report]
    end

    def reject
      @report = Report.find(params[:report_id])
      @report.update(submit_denial_reason_id: nil) if @report.submit_denial_reason.present?
      @report.reject!
      redirect_to admin_report_path(@report, anchor: "start-page")
    end

    private

    def default_index_params
      params = { state_in: ["submitted", "assessing"] }
      if s = Session.current
        params[:session_id_in] = s.id
      end
      params
    end

    def report_params
      params.permit(report: [ :expert_id,
                              :illustration_points,
                              :statement_points,
                              :summary_points ],
                    report_reply: [ :message ])
    end
  end
end
