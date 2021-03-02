module Core
  class CountriesController < Core::ApplicationController
    respond_to :json

    def index
      @countries = Country.finder(params[:q]).order(:title_ru)
      json = { records: @countries.map(&:to_json_with_titles).as_json(for: :ajax), total: @countries.count }
      respond_with(json)
    end
  end
end
