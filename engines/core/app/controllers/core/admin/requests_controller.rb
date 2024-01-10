require 'set'

module Core
  class Admin::RequestsController < Admin::ApplicationController
    before_action :setup_default_filter, only: :index
    before_action :octo_authorize!

    def index
      @search = Request.search(params[:q])
      @requests = @search.result(distinct: true).order(created_at: :desc).preload(:project)
      without_pagination(:requests)
    end

    def show
      @request = Request.find(params[:id])
    end

    def edit
      @request = Request.find(params[:id])
    end

    def update
      @request = Request.find(params[:id])
      if @request.update(request_params)
        redirect_to [:admin, @request], notice: t("flash.request_updated")
      else
        render :edit
      end
    end

    def approve
      Request.find(params[:id]).approve!
      redirect_to admin_requests_path
    end

    def reject
      Request.find(params[:id]).reject!
      redirect_to admin_requests_path
    end

    def activate_or_reject
      @request = Request.find(params[:id])
      unless params[:request][:reason].present?
        flash_message :error, t('.reason_empty')
        redirect_to [:admin, @request]
        return
      end
      if params[:commit] == Core::Request.human_state_event_name(:approve)
        @request.approve!
      else
        @request.reject!
      end
      @request.reason = params[:request][:reason]
      @request.changed_by = current_user
      @request.save!
      redirect_to [:admin, @request]
    end

    def find_similar
      request = Request.find(params[:id])
      cur_project = request.project
      @project_name = cur_project.title
      @project_org = cur_project.organization
      similar_projects = Project
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
      request = Request.find(params[:id])
      cur_project = request.project
      @project_name = cur_project.title
      user_ids = cur_project.users.pluck(:id)
      similar_projects = Project
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


    private
    ProjectWithInfo = Struct.new(:title, :state,  :organization, :logins, 
      :resources, :critical_technologies,
      :direction_of_sciences, :research_areas, :report_marks, :project_id, :organization_id, :human_state_name)

    ResourcesInfo = Struct.new(:name, :value, :measurement, :time)
    SessionsMarks = Struct.new(:illustration_points, :statement_points, :summary_points, :report_id, :time)

    def setup_default_filter
      params[:q] ||= { state_in: ["pending"] }
      params[:q][:meta_sort] ||= "created_at.desc"
    end

    def request_params
      params.require(:request).permit(:cluster_id,
                                      fields_attributes: [:id, :quota_kind_id, :value])
    end
  end
end
