module Comments
  class Admin::ApplicationController < Comments::ApplicationController
    layout 'layouts/comments/admin'
    before_action :check_abilities, :journal_user

    def journal_user
      logger.info "JOURNAL: url=#{request.url}/#{request.method}; user_id=#{current_user ? current_user.id : 'none'}"
    end
  end
end
