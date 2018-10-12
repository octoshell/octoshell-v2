module Core
  class Admin::ProjectsController < Admin::ApplicationController
    def index
      respond_to do |format|
        format.html do
          @search = Project.search(params[:q])
          @projects = @search.result(distinct: true).preload(owner: [:profile])
                             .preload(:organization).order(created_at: :desc)
          @count_all_members = Member.group(:project_id)
          @count_allowed_members = User.group('core_projects.id')
                                       .cluster_access_state_present
          unless display_all_applied?
            @projects = @projects.page(params[:page])
            @count_all_members = @count_all_members.where(project_id: @projects.map(&:id))
            @count_allowed_members = @count_allowed_members.where(core_projects: { id: @projects.map(&:id) } )
          end
          @count_all_members = Hash[@count_all_members.count('id')]
          @count_allowed_members = Hash[@count_allowed_members.count('users.id')]
        end
        format.json do
          @projects = Project.finder(params[:q]).order(:title)
          render json: { records: @projects.page(params[:page]).per(params[:per]), total: @projects.count }
        end
      end
    end

    def show
      @project = Project.find(params[:id])
      respond_to do |format|
        format.html
        format.json { render json: @project }
      end
    end

    def edit
      @project = current_user.owned_projects.find(params[:id])
    end

    def update
      @project = current_user.owned_projects.find(params[:id])
      if @project.update(project_params)
        @project.save
        redirect_to [:admin, @project], notice: t("flash.project_updated")
      else
        render :edit
      end
    end

    def activate
      @project = Project.find(params[:id])
      @project.activate!
      @project.save
      redirect_to [:admin, @project]
    end

    def block
      @project = Project.find(params[:id])
      @project.block!
      @project.save
      redirect_to [:admin, @project]
    end

    def unblock
      @project = Project.find(params[:id])
      @project.unblock!
      redirect_to [:admin, @project]
    end

    def resurrect
      @project = Project.find(params[:id])
      @project.resurrect!
      @project.save
      redirect_to [:admin, @project]
    end

    def finish
      @project = Project.find(params[:id])
      @project.finish!
      @project.save
      redirect_to [:admin, @project]
    end

    def synchronize_with_clusters
      project = Project.find(params[:id])
      project.synchronize!

      head :ok
    end

    def toggle_member_access_state
      member = Member.find(params[:member_id])
      member.toggle_project_access_state!
      member.save

      head :ok
    end

    private

    def project_params
      params.require(:project).permit(:title, :organization_id,
                                      :kind_id,
                                      :organization_department_id,
                                      :research_area_ids,
                                      direction_of_science_ids: [],
                                      critical_technology_ids: [],
                                      card_attributes: ProjectCard::ALL_FIELDS)
    end

    def setup_default_filter
      params[:q] ||= { state_in: ["active"] }
      params[:q][:meta_sort] ||= "created_at.desc"
    end
  end
end
