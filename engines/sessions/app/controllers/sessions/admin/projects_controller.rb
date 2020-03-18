# encoding: utf-8
module Sessions
  if ExternalLink.link?(:project)
    class Admin::ProjectsController < Admin::ApplicationController
      octo_use(:project_class, :core, 'Project')
      octo_use(:organization_class, :core, 'Organization')
      octo_use(:organization_kind_class, :core, 'OrganizationKind')
      octo_use(:project_kind_class, :core, 'ProjectKind')

      before_action :octo_authorize!

      def show_projects
        @session = Session.find(params[:session_id])
        params[:q] ||= { state_in: ["active"] }
        @search = project_class.search(params[:q])
        @projects = @search.result(distinct: true).preload(owner: [:profile]).preload(:organization).order(id: :desc)
        @projects_involved_in_session_ids = @session.involved_project_ids
      end

      def select_projects
        @session = Session.find(params[:session_id])
        @session.moderate_included_projects((params[:selected_project_ids] || []).map(&:to_i))
        redirect_to [:admin, @session]
      end
    end
  end
end
