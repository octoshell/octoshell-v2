module Core
  class ApplicationController < ActionController::Base
    include AuthMayMay
    layout "layouts/application"

    def provide_cities_hash
      @countries_meth = Country.all.order(:title_ru).includes(:cities).to_a
      @countries = @countries_meth
      @cities = {}
      @countries = @countries.map do |c|
        @cities[c.id] = c.cities.to_a.map(&:to_json_with_titles)
        c.to_json_with_titles
      end
    end
  end
end
