module Support
  class ApplicationController < ::ApplicationController #ActionController::Base
    #
    layout "layouts/application"
    before_action :require_login

#    before_action :journal_user

#    def journal_user
#      logger.info "JOURNAL: url=#{request.url}/#{request.method}; user_id=#{current_user ? current_user.id : 'none'}"
#    end
  end
end
