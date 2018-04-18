module Core
  class CitiesController < ApplicationController
    respond_to :json

    def index
      country = Country.find(params[:country_id])
      @cities = country.cities.finder(params[:q]).order(:title_ru)
      json = { records: @cities.page(params[:page]).per(params[:per]), total: @cities.count }
      respond_with(json)
    end

    def index_for_country
      @cities = City.where(country_id: params[:country_id])
      @records = @cities.map(&:to_json_with_titles)
      render json: @records
    end

    def show
      country = Country.find(params[:country_id])
      @city = country.cities.find(params[:id])
      respond_with({ id: @city.id, text: @city.title_ru })
    end
  end
end
