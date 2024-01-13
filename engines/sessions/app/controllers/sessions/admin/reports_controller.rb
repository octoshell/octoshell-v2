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
    without_pagination :reports
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

      res = {}
      similar_projects = Core::Project.where("core_projects.organization_id = ? AND core_projects.id != ?", 
          cur_project.organization_id,
          cur_project.id)
      
      similar_projects.each do |project|
        new_project = ProjectWithInfo.new()
        new_project.title = project.title
        new_project.human_state_name = project.state
        new_project.state = project.state
        new_project.organization_id = project.organization_id
        new_project.logins = Set.new([])
        new_project.critical_technologies = Set.new([])
        new_project.direction_of_sciences = Set.new([])
        new_project.research_areas = Set.new([])
        new_project.report_marks = Set.new([])
        new_project.resources = Set.new([])
        res[project.id] = new_project
      end

      with_organization = similar_projects.includes(:organization)
      with_organization.each do |project|
        res[project.id].organization = project.organization.name
      end

      with_ct = similar_projects.includes(:critical_technologies)
      with_ct.each do |project|
        project.critical_technologies.each do |ct|
          res[project.id].critical_technologies.add(ct.name_ru)
        end
      end

      with_ds = similar_projects.includes(:direction_of_sciences)
      with_ds.each do |project|
        project.direction_of_sciences.each do |ct|
          res[project.id].direction_of_sciences.add(ct.name_ru)
        end
      end

      with_ra = similar_projects.includes(:research_areas)
      with_ra.each do |project|
        project.research_areas.each do |ct|
          res[project.id].research_areas.add(ct.name_ru)
        end
      end

      with_users = similar_projects.includes(users: :profile)
      with_users.each do |project|
        project.users.each do |c|
          user_info = c.profile.first_name + " " + c.profile.last_name + " " + c.email
          res[project.id].logins.add(user_info)
        end
      end
  
      with_requests = similar_projects.includes(requests: {fields: :quota_kind})
      with_requests.each do |project|
        project.requests.each do |req|
          req.fields.each do |field|
            cur_resources_info = ResourcesInfo.new(
              field.quota_kind.name_ru, 
              field.value, 
              field.quota_kind.measurement_ru, 
              project.created_at)
            res[project.id].resources.add(cur_resources_info)
          end
        end
      end

      with_sessions = similar_projects
        .joins('INNER JOIN "sessions_reports" ON "core_projects"."id"="sessions_reports"."project_id"')
        .select("
          illustration_points,
          summary_points,
          core_projects.id as id,
          sessions_reports.id as report_id,
          sessions_reports.updated_at as report_time,
          statement_points
        ")
      with_sessions.each do |project|
        cur_marks_info = SessionsMarks.new(
          project.illustration_points, 
          project.statement_points, 
          project.summary_points, 
          project.report_id, 
          project.report_time)
        res[project.id].report_marks.add(cur_marks_info)
      end
      @project_wth_members = res
    end


    def find_similar_by_members
      request = Report.find(params[:id])
      cur_project = request.project
      @project_name = cur_project.title
      user_ids = cur_project.users.pluck(:id)
      res = {}
      similar_projects = Core::Project.joins(:users).where(users: { id: user_ids }).distinct
      
      similar_projects.each do |project|
        new_project = ProjectWithInfo.new()
        new_project.title = project.title
        new_project.human_state_name = project.state
        new_project.state = project.state
        new_project.organization_id = project.organization_id
        new_project.logins = Set.new([])
        new_project.critical_technologies = Set.new([])
        new_project.direction_of_sciences = Set.new([])
        new_project.research_areas = Set.new([])
        new_project.report_marks = Set.new([])
        new_project.resources = Set.new([])
        res[project.id] = new_project
      end

      with_organization = similar_projects.includes(:organization)
      with_organization.each do |project|
        res[project.id].organization = project.organization.name
      end

      with_ct = similar_projects.includes(:critical_technologies)
      with_ct.each do |project|
        project.critical_technologies.each do |ct|
          res[project.id].critical_technologies.add(ct.name_ru)
        end
      end

      with_ds = similar_projects.includes(:direction_of_sciences)
      with_ds.each do |project|
        project.direction_of_sciences.each do |ct|
          res[project.id].direction_of_sciences.add(ct.name_ru)
        end
      end

      with_ra = similar_projects.includes(:research_areas)
      with_ra.each do |project|
        project.research_areas.each do |ct|
          res[project.id].research_areas.add(ct.name_ru)
        end
      end

      with_users = similar_projects.includes(users: :profile)
      with_users.each do |project|
        project.users.each do |c|
          user_info = c.profile.first_name + " " + c.profile.last_name + " " + c.email
          res[project.id].logins.add(user_info)
        end
      end
  
      with_requests = similar_projects.includes(requests: {fields: :quota_kind})
      with_requests.each do |project|
        project.requests.each do |req|
          req.fields.each do |field|
            cur_resources_info = ResourcesInfo.new(
              field.quota_kind.name_ru, 
              field.value, 
              field.quota_kind.measurement_ru, 
              project.created_at)
            res[project.id].resources.add(cur_resources_info)
          end
        end
      end

      with_sessions = similar_projects
        .joins('INNER JOIN "sessions_reports" ON "core_projects"."id"="sessions_reports"."project_id"')
        .select("
          illustration_points,
          summary_points,
          core_projects.id as id,
          sessions_reports.id as report_id,
          sessions_reports.updated_at as report_time,
          statement_points
        ")
      with_sessions.each do |project|
        cur_marks_info = SessionsMarks.new(
          project.illustration_points, 
          project.statement_points, 
          project.summary_points, 
          project.report_id, 
          project.report_time)
        res[project.id].report_marks.add(cur_marks_info)
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
