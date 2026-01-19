module Core
  class Admin::ProjectVersionsController < Admin::ApplicationController
    helper ProjectVersionHelper
    def index
      @project = Core::Project.find(params[:id])
      @search = ProjectVersion.ransack(params[:q])
      @versions = @search.result(distinct: true)
                         .order(created_at: :desc)
                         .page(params[:page])
                         .per(5)
                         .where(project: @project)
    end
  end
end
