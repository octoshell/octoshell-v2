require "ostruct"
module Core
  class ProjectsController < Core::ApplicationController
    before_action :filter_blocked_users, except: %i[index show edit update]
    def index
      respond_to do |format|
        format.html do
          @owned_projects = current_user.owned_projects.order(:id)
          @projects_with_invitation = current_user.projects_with_invitation.order(:id)
          @projects_with_participation = current_user.projects.where.not(id: (@owned_projects.pluck(:id) |
                                                                              @projects_with_invitation.pluck(:id)))
        end
        # format.json do
        #   @projects = Project.finder(params[:q]).order(:title)
        #   render json: { records: @projects.page(params[:page])
        #                                    .per(params[:per]),
        #                  total: @projects.count }
        # end
      end
    end

    def show
      @project = current_user.projects.find(params[:id])
      @user_can_manage_project = (@project.owner.id == current_user.id) # TODO: d'uh... workaround maymay...
      filter_blocked_users if current_user.closed? && !@user_can_manage_project
    end

    def new
      @project = current_user.owned_projects.build
      @project.build_card
      prepare_categories
    end

    def create
      @project = current_user.owned_projects.build(project_params)
      assign_categories
      if ProjectVersion.user_update(@project)
        redirect_to @project, notice: t("flash.project_created")
      else
        render :new
      end
    end

    def edit
      @project = current_user.owned_projects.find(params[:id])
      prepare_categories
    end

    def update
      @project = current_user.owned_projects.find(params[:id])
      @project.assign_attributes(project_params)
      assign_categories
      if ProjectVersion.user_update(@project)
        redirect_to @project, notice: t("flash.project_updated")
      else
        render :edit
      end
    end

    %i[suspend reactivate cancel resurrect finish].each do |name|
      define_method(name) do
        @project = current_user.owned_projects.find(params[:id])
        ProjectVersion.trigger_event(@project, name)
        redirect_to @project
      end
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
      unless member.project.member_owner.user_id == current_user.id
        head :forbidden
        return
      end
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

    def assign_categories
      %i[direction_of_sciences critical_technologies research_areas].each do |type|
        join_assoc = @project.send("project_#{type}")
        singular_id = "#{type.to_s.singularize}_id"
        ids = Array(params[:project]["meta_#{type.to_s.singularize}_ids"])

        ids = ids.select(&:present?).map(&:to_i).uniq
        join_assoc.each do |j|
          j.mark_for_destruction unless ids.delete(j.send(singular_id))
        end
        ids.each do |id|
          join_assoc.build(singular_id => id)
        end
      end
      prepare_categories
    end

    def prepare_categories
      %i[direction_of_sciences critical_technologies research_areas].each do |type|
        @project.define_singleton_method("meta_#{type.to_s.singularize}_ids") do
          join_assoc = send("project_#{type}")
          join_assoc.reject(&:marked_for_destruction?).map do |j|
            j.send("#{type.to_s.singularize}_id")
          end
        end
      end
    end


    def project_params
      params.require(:project).permit(:title, :organization_id,
                                      :organization_department_id,
                                      :kind_id,
                                      :estimated_finish_date,
                                      card_attributes: ProjectCard::ALL_FIELDS + [:id])
    end
  end
end
