module Core
  class OrganizationsController < ApplicationController
    respond_to :json

    def index
      @organizations = Organization.finder(params[:q])
      json = {
        records: @organizations.page(params[:page]).per(params[:per]),
        total: @organizations.count
      }
      respond_with(json)
    end

    def show
      @organization = Organization.find(params[:id])
      respond_with({ id: @organization.id, text: @organization.name })
    end

    def new
      @organization = Organization.new
    end

    def create
      @organization = Organization.new(organization_params)
      if @organization.save
        if @organization.kind.departments_required?
          redirect_to [:edit, @organization], notice: t("flash.you_have_to_fill_departments")
        else
          @organization.departments.create!(name: @organization.short_name)
          redirect_to new_employment_path(organization_id: @organization.id), notice: t("flash.organization_has_been_created", default: "Organization has been created")
        end
      else
        render :new
      end
    end

    def edit
      @organization = Organization.find(params[:id])
    end

    def update
      @organization = Organization.find(params[:id])
      if @organization.update(organization_params)
        redirect_to new_employment_path(current_user.employments.build), notice: t("flash.organization_created", default: "Organization has been created")
      end
    end

    private

    def organization_params
      params.require(:organization).permit(:name, :abbreviation, :country_id,
                                           :city_title, :city_id, :kind_id,
                                           departments_attributes: [ :name ])
    end
  end
end
