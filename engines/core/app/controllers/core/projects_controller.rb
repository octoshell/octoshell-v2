module Core
  class ProjectsController < Core::ApplicationController
    before_action :filter_blocked_users, except: :index
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
        @project.save
        redirect_to @project, notice: t("flash.project_updated")
      else
        render :edit
      end
    end

    def suspend
      @project = current_user.owned_projects.find(params[:id])
      @project.suspend!
      @project.save
      redirect_to @project
    end

    def reactivate
      @project = current_user.owned_projects.find(params[:id])
      @project.reactivate!
      @project.save
      redirect_to @project
    end

    def cancel
      @project = current_user.owned_projects.find(params[:id])
      @project.cancel!
      redirect_to @project
    end

    def resurrect
      @project = current_user.owned_projects.find(params[:id])
      @project.resurrect!
      @project.save
      redirect_to @project
    end

    def finish
      @project = current_user.owned_projects.find(params[:id])
      @project.finish!
      @project.save
      redirect_to @project
    end

    def invite_member
      begin
        @project = current_user.owned_projects.find(params[:id])
        @project.invite_member(params.fetch(:member)[:id])
        @project.save
      rescue ActiveRecord::RecordNotUnique
        flash_message :alert, t('flash.duplicated_invite')
      end

      unless @project.errors.empty?
        flash_message :alert, @project.errors.full_messages.to_sentence
      end

      redirect_to @project
    end

    def drop_member
      @project = current_user.owned_projects.find(params[:id])
      @project.drop_member(params.fetch(:user_id))
      @project.save

      redirect_to @project
    end

    def toggle_member_access_state
      member = Member.find(params[:member_id])
      member.toggle_project_access_state!
      member.save

      head :ok
    end

    def invite_users_from_csv
      @project = current_user.owned_projects.find(params[:id])
      if params[:invitation].nil?
        return redirect_to @project, notice: t("flash.no_file_selected")
      end
      file = params[:invitation][:csv_file]
      begin
        CSV.foreach(file.path) do |row|
          email = row.first.downcase
          initials = row.second
          language = row.third || current_user.language
          user = User.find_by_email(email)
          if user.present?
            @project.invite_member(user.id) unless @project.users.exists?(id: user.id)
          else
            if I18n.available_locales.map(&:to_s).exclude? language
              raise "Language is invalid"
            end
            @project.invitations.create_with(language: language)
                    .find_or_create_by!(user_email: email, user_fio: initials)
          end
        end
      rescue => e
        return redirect_to @project, notice: t("flash.bad_csv_file")+e.message
      end
      @project.save
      redirect_to @project
    end

    def resend_invitations
      @project = current_user.owned_projects.find(params[:id])
      @project.invitations.all.each(&:send_email_to_user_with_save)
      redirect_to @project
    end

    def delete_invitation
      @project = current_user.owned_projects.find(params[:id])
      @project.invitations.find(params[:invitation_id]).destroy
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
