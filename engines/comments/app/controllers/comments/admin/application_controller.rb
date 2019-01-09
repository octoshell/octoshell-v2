module Comments
  class Admin::ApplicationController < Comments::ApplicationController
    layout 'layouts/comments/admin'
    before_filter :check_abilities, :journal_user
    def check_abilities
      authorize! :manage, :comments_engine
    end

    def journal_user
      logger.info "JOURNAL: url=#{request.url}/#{request.method}; user_id=#{current_user ? current_user.id : 'none'}"
    end
  end
end
