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

      res = {}
      similar_projects = Project.where("core_projects.organization_id = ? AND core_projects.id != ?",
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
          user_info = "#{c.profile.first_name} #{c.profile.last_name} #{c.email}}"
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
      request = Request.find(params[:id])
      cur_project = request.project
      @project_name = cur_project.title
      user_ids = cur_project.users.pluck(:id)
      res = {}
      similar_projects = Project.joins(:users).where(users: { id: user_ids }).distinct

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
          user_info = "#{c.profile.first_name} #{c.profile.last_name} #{c.email}}"
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


    private
    ProjectWithInfo = Struct.new(:title, :state, :organization, :logins,
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
