module Core
  class Admin::ApplicationController < Core::ApplicationController
    before_action :authorize_admins, :journal_user
    skip_before_action :filter_blocked_users

    def authorize_admins
      authorize! :access, :admin
    end

    def journal_user
      logger.info "JOURNAL: url=#{request.url}/#{request.method}; user_id=#{current_user ? current_user.id : 'none'}"
    end
  end
end
