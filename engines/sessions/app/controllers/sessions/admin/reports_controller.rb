module Sessions
  class Admin::ReportsController < Admin::ApplicationController
    # before_action { authorize! :manage, :reports }
    before_action :octo_authorize!
    octo_use(:project_class, :core, 'Project')
    # octo_use(:group_research_area_class, :core, 'GroupOfResearchArea')
    # octo_use(:critical_technology_class, :core, 'CriticalTechnology')
    # octo_use(:direction_of_science_class, :core, 'DirectionOfScience')
    # octo_use(:research_area_class, :core, 'ResearchArea')

    def index
      @search = Report.includes([{ author: :profile },
                                 { expert: :profile }, :session])
                      .for_link(:project) { |r| r.includes(project: :research_areas) }
                      .search(params[:q] || default_index_params)
      @reports = if (User.superadmins | User.reregistrators).include? current_user
                   @search.result(distinct: true)
                 elsif User.experts.include? current_user
                   @search.result(distinct: true).
                     where(expert_id: [nil, current_user.id])

                 end
      if params[:csv]
        send_csv
        return
      end
      without_pagination :reports
    end

    def send_csv
      headers = ['project_owner', 'project_id', 'project_title', 'link', '
        summary_points', 'illustration_points', 'statement_points']
      csv_string = CSV.generate do |csv|
        csv << headers
        @reports.includes(project: {owner: :profile}).each do |report|
          csv << [
            report.project.owner.full_name,
            report.project_id,
            report.project.title,
            admin_report_url(report),
            report.summary_points,
            report.illustration_points,
            report.statement_points
          ]
        end
      end
      send_data csv_string, filename: "reports-#{Date.today}.csv",
                            disposition: :attachment
    end

    def edit
      @report = Report.find(params[:report_id])
      @report.edit!
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
      @report.save

      redirect_to [:admin, @report]
    end

    def assess
      @report = Report.find(params[:report_id])
      if current_user == @report.expert
        @report.assign_attributes(report_params[:report] || {})
        @report.assess!
        redirect_to [:admin, @report]
      elsif @report.expert.nil? && Sessions.user_class.experts.include?(current_user)
        @report.expert = current_user
        @report.pick!
        @report.assign_attributes(report_params)
        @report.assess!
        @report.save
        redirect_to [:admin, @report]
      else
        raise CanCan::AccessDenied
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
      @report.save
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
