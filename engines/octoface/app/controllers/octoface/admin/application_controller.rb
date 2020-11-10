module Octoface::Admin
  class ApplicationController < ::ApplicationController
    layout "layouts/octoface/admin"

    before_action :check_abilities, :journal_user
    def check_abilities
      authorize! :show, :octoface
    end

    def journal_user
      logger.info "JOURNAL: url=#{request.url}/#{request.method}; user_id=#{current_user ? current_user.id : 'none'}"
    end
  end
end
