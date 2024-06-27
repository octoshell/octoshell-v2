# encoding: utf-8
module Sessions
  if link?(:project)
    class Admin::ProjectsController < Admin::ApplicationController
      octo_use(:project_class, :core, 'Project')
      before_action :octo_authorize!

      def show_projects
        @session = Session.find(params[:session_id])
        params[:q] ||= { state_in: ["active"] }
        if params[:q][:choose_to_hide] && !params[:q][:choose_to_hide][0].present?
          params[:q].delete(:choose_to_hide)
        end
        @search = project_class.ransack(params[:q])
        @choose_to_hide = @search.choose_to_hide || []
        @projects = @search.result(distinct: true).preload(owner: [:profile]).preload(:organization).order(id: :desc)
        @projects_involved_in_session_ids = @session.involved_project_ids
      end

      def select_projects
        @session = Session.find(params[:session_id])
        remain_ids = to_i_from_params(:selected_project_ids) +
        (@session.involved_project_ids -
          params[:project_ids].split(' ').map(&:to_i)).uniq
        @session.moderate_included_projects(remain_ids)
        redirect_to [:admin, @session]
      end

      private

      def to_i_from_params(key)
        (params[key] || []).map(&:to_i)
      end

    end
  end
end
