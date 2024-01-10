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

    def find_similar
      request = Report.find(params[:id])
      cur_project = request.project
      @project_name = cur_project.title
      @project_org = cur_project.organization
      similar_projects = Core::Project
        .where("core_projects.organization_id = ? AND core_projects.id != ?", 
          cur_project.organization_id,
          cur_project.id)
        .joins(:users)
        .joins(users: :profile)
        .joins(:organization)
        .joins(requests: {fields: :quota_kind})
        .joins(:critical_technologies)
        .joins(:direction_of_sciences)
        .joins(:research_areas)
        .joins('INNER JOIN "sessions_reports" ON "core_projects"."id"="sessions_reports"."project_id"')
        .select("title, core_projects.state, email, name, value, 
          core_quota_kinds.name_ru as qname, 
          measurement_ru,
          core_critical_technologies.name_ru as ctname,
          core_direction_of_sciences.name_ru as dsname,
          core_research_areas.name_ru as raname,
          illustration_points,
          summary_points,
          core_requests.created_at as request_time,
          core_projects.id as project_id,
          core_organizations.id as organization_id,
          sessions_reports.id as report_id,
          sessions_reports.updated_at as report_time,
          statement_points,
          first_name,
          last_name
        ")
      res = {}


      similar_projects.each do |project|
        user_info = project.first_name + " " + project.last_name + " " + project.email
        cur_resources_info = ResourcesInfo.new(project.qname, project.value, project.measurement_ru, project.request_time)
        cur_marks_info = SessionsMarks.new(project.illustration_points, project.statement_points, project.summary_points,
          project.report_id, project.report_time)
        if res.has_key?(project.title)
          prev_project = res[project.title]
          if !prev_project.logins.include?(user_info)
            prev_project.logins.add(user_info)
          end
          if !prev_project.resources.include?(cur_resources_info)
            prev_project.resources.add(cur_resources_info)
          end
          if !prev_project.critical_technologies.include?(project.ctname)
            prev_project.critical_technologies.add(project.ctname)
          end
          if !prev_project.direction_of_sciences.include?(project.dsname)
            prev_project.direction_of_sciences.add(project.dsname)
          end
          if !prev_project.research_areas.include?(project.raname)
            prev_project.research_areas.add(project.raname)
          end
          if !prev_project.report_marks.include?(cur_marks_info)
            prev_project.report_marks.add(cur_marks_info)
          end
        else
          project_with_info = ProjectWithInfo.new(
            project.title,
            project.state,
            project.name,
            Set.new([user_info]),
            Set.new([cur_resources_info]),
            Set.new([project.ctname]),
            Set.new([project.dsname]),
            Set.new([project.raname]),
            Set.new([cur_marks_info]),
            project.project_id,
            project.organization_id,
            project.state,
          )
          res[project.title] = project_with_info
        end
      end
      @project_wth_members = res
    end


    def find_similar_by_members
      request = Report.find(params[:id])
      cur_project = request.project
      @project_name = cur_project.title
      user_ids = cur_project.users.pluck(:id)
      similar_projects = Core::Project
        .joins(:users)
        .joins(users: :profile)
        .where(users: { id: user_ids }).distinct
        .joins(:organization)
        .joins(requests: {fields: :quota_kind})
        .joins(:critical_technologies)
        .joins(:direction_of_sciences)
        .joins(:research_areas)
        .joins('INNER JOIN "sessions_reports" ON "core_projects"."id"="sessions_reports"."project_id"')
        .select("title, core_projects.state, email, name, value, 
          core_quota_kinds.name_ru as qname, 
          measurement_ru,
          core_critical_technologies.name_ru as ctname,
          core_direction_of_sciences.name_ru as dsname,
          core_research_areas.name_ru as raname,
          core_projects.id as project_id,
          core_organizations.id as organization_id,
          core_requests.created_at as request_time,
          sessions_reports.updated_at as report_time,
          sessions_reports.id as report_id,
          illustration_points,
          summary_points,
          statement_points,
          last_name,
          first_name
        ")
      res = {}


      similar_projects.each do |project|
        user_info = project.first_name + " " + project.last_name + " " + project.email
        cur_resources_info = ResourcesInfo.new(project.qname, project.value, project.measurement_ru, project.request_time)
        cur_marks_info = SessionsMarks.new(project.illustration_points, project.statement_points, project.summary_points, 
          project.report_id, project.report_time)
        if res.has_key?(project.title)
          prev_project = res[project.title]
          if !prev_project.logins.include?(user_info)
            prev_project.logins.add(user_info)
          end
          if !prev_project.resources.include?(cur_resources_info)
            prev_project.resources.add(cur_resources_info)
          end
          if !prev_project.critical_technologies.include?(project.ctname)
            prev_project.critical_technologies.add(project.ctname)
          end
          if !prev_project.direction_of_sciences.include?(project.dsname)
            prev_project.direction_of_sciences.add(project.dsname)
          end
          if !prev_project.research_areas.include?(project.raname)
            prev_project.research_areas.add(project.raname)
          end
          if !prev_project.report_marks.include?(cur_marks_info)
            prev_project.report_marks.add(cur_marks_info)
          end

        else
          project_with_info = ProjectWithInfo.new(
            project.title,
            project.state,
            project.name,
            Set.new([user_info]),
            Set.new([cur_resources_info]),
            Set.new([project.ctname]),
            Set.new([project.dsname]),
            Set.new([project.raname]),
            Set.new([cur_marks_info]),
            project.project_id,
            project.organization_id,
            project.state,
          )
          res[project.title] = project_with_info
        end
      end
      @project_wth_members = res
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
    ProjectWithInfo = Struct.new(:title, :state,  :organization, :logins, 
    :resources, :critical_technologies,
    :direction_of_sciences, :research_areas, :report_marks, :project_id, :organization_id, :human_state_name)

    ResourcesInfo = Struct.new(:name, :value, :measurement, :time)
    SessionsMarks = Struct.new(:illustration_points, :statement_points, :summary_points, :report_id, :time)

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
