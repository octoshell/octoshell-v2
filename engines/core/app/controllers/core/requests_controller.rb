module Core
  class RequestsController < ApplicationController
    def new
      @project = obtain_project
      @cluster_id = params[:cluster_id]
      @request = @project.requests.build
      @request.fill_fields_from_cluster!(@cluster_id)
    end

    def create
      @project = obtain_project
      new_request = @project.requests.create!(request_params)
      redirect_to @project, notice: t("flash.request_created")
    end

    private

    def obtain_project
      current_user.owned_projects.find(params[:project_id])
    end

    def request_params
      params.require(:request).permit(:cluster_id,
                                      fields_attributes: [:id, :quota_kind_id, :value])
    end
  end
end
