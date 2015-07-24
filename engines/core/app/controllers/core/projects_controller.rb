module Core
  class ProjectsController < ApplicationController
    def index
      respond_to do |format|
        format.html do
          @owned_projects = current_user.owned_projects.order(:id)
          @projects_with_invitation = current_user.projects_with_invitation.order(:id)
          @projects_with_participation = current_user.projects.where.not(id: (@owned_projects.pluck(:id) |
                                                                              @projects_with_invitation.pluck(:id)))
        end
        format.json do
          @projects = Project.finder(params[:q]).order(:title)
          render json: { records: @projects.page(params[:page]).per(params[:per]), total: @projects.count }
        end
      end
    end

    def show
      @project = current_user.projects.find(params[:id])
      @user_can_manage_project = (@project.owner.id == current_user.id) # TODO: d'uh... workaround maymay...
    end

    def new
      @project = current_user.owned_projects.build
      @project.build_card
    end

    def create
      @project = current_user.owned_projects.build(project_params)
      if @project.save
        redirect_to @project, notice: t("flash.project_created")
      else
        render :new
      end
    end

    def edit
      @project = current_user.owned_projects.find(params[:id])
    end

    def update
      @project = current_user.owned_projects.find(params[:id])
      if @project.update(project_params)
        redirect_to @project, notice: t("flash.project_updated")
      else
        render :edit
      end
    end

    def destroy
      @project = Project.find(params[:id])
      @project.destroy!
      redirect_to projects_path
    end

    def suspend
      @project = Project.find(params[:id])
      @project.suspend!
      redirect_to @project
    end

    def reactivate
      @project = Project.find(params[:id])
      @project.reactivate!
      redirect_to @project
    end

    def cancel
      @project = Project.find(params[:id])
      @project.cancel!
      redirect_to @project
    end

    def resurrect
      @project = Project.find(params[:id])
      @project.resurrect!
      redirect_to @project
    end

    def finish
      @project = Project.find(params[:id])
      @project.finish!
      redirect_to @project
    end

    def invite_member
      @project = current_user.owned_projects.find(params[:id])
      @project.invite_member(params.fetch(:member)[:id])

      unless @project.errors.empty?
        flash[:alert] = @project.errors.full_messages.to_sentence
      end

      redirect_to @project
    end

    def drop_member
      @project = current_user.owned_projects.find(params[:id])
      @project.drop_member(params.fetch(:user_id))

      redirect_to @project
    end

    def toggle_member_access_state
      member = Member.find(params[:member_id])
      member.toggle_project_access_state!

      head :ok
    end

    def invite_users_from_csv
      @project = current_user.owned_projects.find(params[:id])
      file = params[:invitation][:csv_file]
      CSV.foreach(file.path) do |row|
        email = row.first
        initials = row.last
        user = User.find_by_email(email)
        if user.present?
          @project.invite_member(user.id) unless @project.users.exists?(id: user.id)
        else
          @project.invitations.find_or_create_by!(user_email: email, user_fio: initials)
        end
      end
      redirect_to @project
    end

    def resend_invitations
      @project = current_user.owned_projects.find(params[:id])
      @project.invitations.all.map(&:send_email_to_user)
      redirect_to @project
    end

    private

    def project_params
      params.require(:project).permit(:title, :organization_id,
                                      :organization_department_id,
                                      :kind_id,
                                      :estimated_finish_date,
                                      :research_area_ids,
                                      direction_of_science_ids: [],
                                      critical_technology_ids: [],
                                      card_attributes: ProjectCard::ALL_FIELDS)
    end
  end
end
