module Core
  class Admin::ProjectKindsController < Admin::ApplicationController
    def index
      @search = ProjectKind.search(params[:q])
      @project_kinds = @search.result(distinct: true).page(params[:page])
    end

    def show
      @project_kind = ProjectKind.find(params[:id])
    end

    def new
      @project_kind = ProjectKind.new
    end

    def create
      @project_kind = ProjectKind.new(project_kind_params)
      if @project_kind.save
        redirect_to admin_project_kinds_path
      else
        render :new
      end
    end

    def edit
      @project_kind = ProjectKind.find(params[:id])
    end

    def update
      @project_kind = ProjectKind.find(params[:id])
      if @project_kind.update_attributes(project_kind_params)
        redirect_to admin_project_kinds_path
      else
        render :edit
      end
    end

    private

    def project_kind_params
      params.require(:project_kind).permit(:name)
    end
  end
end
