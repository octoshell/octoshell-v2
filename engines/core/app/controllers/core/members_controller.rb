module Core
  class MembersController < Core::ApplicationController

    before_action :filter_blocked_users

    before_action only: %i[edit update] do
      @project = Project.find(params[:project_id])
      @member = @project.members.find(params[:id])
      not_authorized unless @member.user_id == current_user.id
    end

    def edit
    end

    def update
      if @member.update(member_params)
        @member.accept_invitation!
        @member.save
        redirect_to @project
      else
        render :edit
      end
    end

    private

    def member_params
      params.require(:member).permit(:user_id, :organization_id, :organization_department_id)
    end

  end
end
