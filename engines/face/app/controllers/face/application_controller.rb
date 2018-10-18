module Face
  class ApplicationController < ActionController::Base
    layout "layouts/application"
    
    before_filter :journal_user

    def journal_user
      logger.info "JOURNAL: url=#{request.url}/#{request.method}; user_id=#{current_user ? current_user.id : 'none'}"
    end
  end
end
