module Core
  class Admin::OrganizationKindsController < Admin::ApplicationController
    def index
      @search = OrganizationKind.search(params[:q])
      @organization_kinds = @search.result(distinct: true).page(params[:page])
    end

    def show
      @organization_kind = OrganizationKind.find(params[:id])
    end

    def new
      @organization_kind = OrganizationKind.new
    end

    def create
      @organization_kind = OrganizationKind.new(organization_kind_params)
      if @organization_kind.save
        redirect_to [:admin, @organization_kind]
      else
        render :new
      end
    end

    def edit
      @organization_kind = OrganizationKind.find(params[:id])
    end

    def update
      @organization_kind = OrganizationKind.find(params[:id])
      if @organization_kind.update_attributes(organization_kind_params)
        redirect_to [:admin, @organization_kind]
      else
        render :edit
      end
    end

    private

    def organization_kind_params
      params.require(:organization_kind).permit(:name, :departments_required)
    end
  end
end
