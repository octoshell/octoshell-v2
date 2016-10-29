module Core
  class OrganizationDepartmentsController < ApplicationController
    respond_to :json

    def index
      organization = Organization.find(params[:organization_id])
      @departments = organization.departments.finder(params[:q])
      json = { records: @departments.page(params[:page]).per(params[:per]), total: @departments.count}
      respond_with(json)
    end
  end
end
