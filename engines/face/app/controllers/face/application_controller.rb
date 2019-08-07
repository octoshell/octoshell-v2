module Face
  class ApplicationController < ::ApplicationController
    layout "layouts/application"
    
#    before_action :journal_user
#
#    def journal_user
#      logger.info "JOURNAL: url=#{request.url}/#{request.method}; user_id=#{current_user ? current_user.id : 'none'}"
#    end
  end
end
