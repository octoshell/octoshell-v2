module Core
  class SuretiesController < ApplicationController
    before_filter :require_login

    def new
      @project = Project.find(params[:project_id])
      @unsured_members = @project.members.with_project_access_state(:engaged)
      @surety = @project.sureties.build do |surety|
        surety.author = current_user
      end
    end

    def create
      @project = Project.find(params[:surety][:project_id])
      @surety = @project.sureties.build(surety_params) do |surety|
        surety.author = current_user
        @project.members.with_project_access_state(:engaged).each do |project_member|
          surety.surety_members.build(user: project_member.user,
                                      organization: project_member.organization,
                                      organization_department: project_member.organization_department)
        end
      end
      if @surety.save!
        @project.members.with_project_access_state(:engaged).map(&:append_to_surety!)
        redirect_to @project
      else
        redirect_to @project, alert: @surety.errors.full_messages.to_sentence
      end
    end

    def show
      @surety = find_surety(params[:id])
      respond_to do |format|
        format.html
        format.rtf do
          send_data @surety.generate_rtf, filename: "surety_#{@surety.id}.rtf", type: "application/rtf"
        end
      end
    end

    def edit
      @surety = find_surety(params[:id])
    end

    def update
      @surety = find_surety(params[:id])

      if @surety.update(surety_params)
        redirect_to @surety
      else
        redirect_to @surety, alert: @surety.errors.full_messages.to_sentence
      end
    end

    def confirm
      @surety = find_surety(params[:id])
      if @surety.confirm
        redirect_to @surety.project
      else
        redirect_to @surety, alert: @surety.errors.full_messages.to_sentence
      end
    end

    def close
      @surety = find_surety(params[:id])
      if @surety.close
        redirect_to @surety.project
      else
        redirect_to @surety, alert: @surety.errors.full_messages.to_sentence
      end
    end

    private

    def find_surety(id)
      current_user.authored_sureties.find(id)
    end

    def surety_params
      params.require(:surety).permit(:boss_full_name, :boss_position, :project_id,
                                     scans_attributes: [ :image, :id, :_destroy ])
    end
  end
end
