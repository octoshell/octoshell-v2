module Core
  class ApplicationController < ::ApplicationController #ActionController::Base
    # before_action :require_login
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

    def filter_blocked_users
      redirect_to projects_path if current_user.closed?
    end

#    before_action :journal_user
#
#    def journal_user
#      logger.info "JOURNAL: url=#{request.url}/#{request.method}; user_id=#{current_user ? current_user.id : 'none'}"
#    end
  end
end
