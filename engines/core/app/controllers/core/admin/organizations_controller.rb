module Core
  class Admin::OrganizationsController < Admin::ApplicationController
    def index
      respond_to do |format|
        format.html do
          @search = Organization.search(params[:q])
          search_result = @search.result(distinct: true).includes(:kind, :city, :country).order(id: :desc)
          @organizations = search_result.page(params[:page])
        end
        format.json do
          @organizations = Organization.finder(params[:q])
          render json: { records: @organizations.page(params[:page]).per(params[:per]), total: @organizations.count }
        end
      end
    end

    def new
      @organization = Organization.new
    end

    def create
      @organization = Organization.new(organization_params)
      if @organization.save
        if @organization.kind.departments_required?
          redirect_to [:admin, :edit, @organization], notice: t("flash.you_have_to_fill_departments")
        else
          @organization.departments.create!(name: @organization.short_name)
          redirect_to [:admin, @organization]
        end
      else
        render :new
      end
    end

    def show
      @organization = Organization.find(params[:id])

      respond_to do |format|
        format.html
        format.json { render json: @organization }
      end
    end

    def edit
      @organization = Organization.find(params[:id])
    end

    def update
      @organization = Organization.find(params[:id])
      if @organization.update_attributes(organization_params)
        redirect_to [:admin, @organization]
      else
        render :edit
      end
    end

    def merge
      @organization = Organization.find(params[:organization_id])
      @duplication = Organization.find(params[:organization][:merge_id])
      if @organization.merge(@duplication)
        redirect_to [:admin, @organization]
      else
        render :show
      end
    end

    private

    def organization_params
      params.require(:organization).permit(:name, :abbreviation, :city_id, :country_id, :kind_id,
                                           departments_attributes: [ :id, :name, :_destroy ])
    end
  end
end
