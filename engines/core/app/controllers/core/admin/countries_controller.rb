module Core
  class Admin::CountriesController < Admin::ApplicationController
    before_action :octo_authorize!
    def index
      respond_to do |format|
        format.html do
          @search = Country.search(params[:q])
          search_result = @search.result(distinct: true).order(id: :desc)
          @countries = search_result
          without_pagination :countries
        end
        format.json do
          @countries = Country.finder(params[:q])
          @records = @countries
                     .page(params[:page]).per(params[:per])
                     .map { |c| { text: c.titles, id: c.id } }

          json = {
            records: @records,
            total: @countries.count
          }
          render json: json
        end
      end
    end

    def new
      @country = Country.new
    end

    def create
      @country = Country.new(country_params)
      if @country.save
          redirect_to [:admin, @country]
      else
        render :new
      end
    end

    def show
      @country = Country.includes(:cities).find(params[:id])
      @cities = @country.cities.order(:title_ru).page(params[:page]).per(10)
    end

    def edit
      @country = Country.find(params[:id])
    end

    def update
      @country = Country.find(params[:id])
      if @country.update country_params
        redirect_to [:admin, @country]
      else
        render :edit
      end
    end

    def destroy
      @country = Country.find(params[:id])
      if @country.organizations.exists?
        redirect_to [:admin, @country], flash: { error: t('.org_exist') }
      else
        @country.destroy
        redirect_to admin_cities_path
      end
    end


    private

    def country_params
      params.require(:country).permit(:checked, :title_ru, :title_en)
    end
  end
end
