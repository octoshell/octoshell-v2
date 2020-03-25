module Core
  class Admin::CitiesController < Admin::ApplicationController
    before_action :octo_authorize!
    def index
      respond_to do |format|
        format.html do
          @search = City.search(params[:q])
          search_result = @search.result(distinct: true).order(:title_ru)
          @cities = search_result.includes(:country)
          without_pagination :cities
        end
        format.json do
          @cities = City.finder(params[:q]).order(:title_ru)
          json = { records: @cities.page(params[:page]).per(params[:per]), total: @cities.count }
          render json: json
        end

      end
    end

    def merge
      to = Core::City.find(params[:merge_id])
      Core::City.find(params[:id]).merge_with! to
      redirect_to [:admin, to]
    end

    def new
      @city = City.new
      country_id = params[:country_id]
      @city.country_id = country_id if country_id
    end

    def create
      @city = City.new(city_params)
      if @city.save
        redirect_to [:admin, @city]
      else
        render :new
      end
    end

    def show
      @city = City.includes(:country).find(params[:id])
    end

    def edit
      @city = City.includes(:country).find(params[:id])
    end

    def update
      @city = City.includes(:country).find(params[:id])
      if @city.update city_params
        redirect_to [:admin, @city]
      else
        render :edit
      end
    end

    def destroy
      @city = City.find(params[:id])
      if @city.organizations.exists?
        redirect_to [:admin, @city], flash: { error: t('.org_exist') }
      else
        @city.destroy
        redirect_to admin_cities_path
      end
    end

    private

    def city_params
      params.require(:city).permit(:checked, :title_ru, :title_en, :country_id)
    end
  end
end
