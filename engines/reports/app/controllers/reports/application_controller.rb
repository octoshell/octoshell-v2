module Reports
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
    include AuthMayMay
    layout 'layouts/reports/admin'
    before_filter :journal_user, :check_abilities

    def check_abilities
      authorize! :manage, :reports_engine
    end

    def journal_user
      logger.info "JOURNAL: url=#{request.url}/#{request.method}; user_id=#{current_user ? current_user.id : 'none'}"
    end

  end
end
