module Support
  class Admin::ApplicationController < Support::ApplicationController
    layout "layouts/support/admin"

    before_action :authorize_admins, :journal_user
    # rescue_from MayMay::Unauthorized, with: :not_authorized

    def authorize_admins
      authorize!(:access, :admin) && authorize!(:manage, :tickets)
    end

    def not_authorized
      flash_message :alert, t("flash.not_authorized")
      redirect_to main_app.root_path
    end

    def not_authorized_access_to(ticket)
      ticket.topic && !can?(:access, ticket.topic) && raise(CanCan::AccessDenied)
    end

    def journal_user
      logger.info "JOURNAL: url=#{request.url}/#{request.method}; user_id=#{current_user ? current_user.id : 'none'}"
    end
  end
end
