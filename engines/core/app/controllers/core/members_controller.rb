module Core
  class MembersController < ApplicationController
    def edit
      @project = Project.find(params[:project_id])
      @member = @project.members.find(params[:id])
    end

    def update
      @project = Project.find(params[:project_id])
      @member = @project.members.find(params[:id])
      if @member.update(member_params)
        @member.accept_invitation!
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
