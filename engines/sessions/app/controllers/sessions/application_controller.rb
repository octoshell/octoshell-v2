module Sessions
  class ApplicationController < ::ApplicationController
    helper Face::ApplicationHelper
    before_action do
      @extra_js = 'sessions/application'
      @extra_css = 'sessions/application'

    end
    before_action :require_login
    layout "layouts/application"
    #before_action :journal_user

    #def journal_user
    #  logger.info "JOURNAL: url=#{request.url}/#{request.method}; user_id=#{current_user ? current_user.id : 'none'}"
    #end
  end
end
