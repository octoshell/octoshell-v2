module Core
  class ApplicationController < ActionController::Base
    layout "layouts/application"
    before_filter :require_login

    rescue_from MayMay::Unauthorized, with: :not_authorized

    def not_authenticated
      redirect_to main_app.root_path, alert: t("flash.not_logged_in")
    end

    def not_authorized
      redirect_to main_app.root_path, alert: t("flash.not_authorized")
    end


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
