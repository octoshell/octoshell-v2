module Core
  class OrganizationsController < Core::ApplicationController
    respond_to :json

    before_action :filter_blocked_users, except: :index


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
      @employment = @organization.employments.new
    end

    def create
      @organization = Organization.new(organization_params)
      @employment = @organization.employments.new(employment_params)
      @employment.user = current_user
      new_city = params[:organization][:city_title].to_s
      if new_city.present? && @organization.country
        @organization.city_title = new_city
        @organization.city.save!
        @organization.city.create_ticket(current_user) if @organization.city.previous_changes['id']
      end
      if @organization.save
        @organization.create_ticket(current_user)
        if @organization.kind.departments_required?
          redirect_to [:edit, @organization], notice: t("flash.you_have_to_fill_departments")
        else
          @organization.departments.create!(name: @organization.short_name)
          redirect_to @employment
        end
      else
        render :new
      end
    end

    def edit
      @organization = Organization.find(params[:id])
      can_edit
    end

    def update
      @organization = Organization.find(params[:id])
      can_edit
      if @organization.update(organization_params)
        @organization.departments.each do |d|
          d.create_ticket(current_user) if d.previous_changes['id']
        end
        redirect_to main_app.profile_path
      else
        render :edit
      end
    end


    private

    def can_edit
      raise MayMay::Unauthorized unless @organization.can_edit?(current_user)
      # redirect_to(main_app.profile_path)
    end

    def employment_params
      params.require(:employment).permit(:primary)
    end

    def organization_params
      params.require(:organization).permit(:name, :abbreviation, :country_id,
                                           :city_title, :city_id, :kind_id, :_destroy,
                                           departments_attributes: [ :id, :_destroy, :name ])
    end
  end
end
