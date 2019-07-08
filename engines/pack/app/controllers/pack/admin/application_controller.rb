module Pack
  class Admin::ApplicationController < Pack::ApplicationController
    layout "layouts/pack/admin"

    before_action :check_abilities, :journal_user
    def check_abilities
      authorize! :manage, :packages
    end

    def journal_user
      logger.info "JOURNAL: url=#{request.url}/#{request.method}; user_id=#{current_user ? current_user.id : 'none'}"
    end
  end
end
