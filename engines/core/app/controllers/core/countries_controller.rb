module Core
  class CountriesController < ApplicationController
    respond_to :json

    def index
      @countries = Country.finder(params[:q])
      json = { records: @countries.map(&:title_ru).as_json(for: :ajax), total: @countries.count }
      respond_with(json)
    end
  end
end
