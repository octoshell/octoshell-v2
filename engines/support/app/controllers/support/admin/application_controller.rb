module Support
  class Admin::ApplicationController < Support::ApplicationController
    layout "layouts/support/admin"

    before_filter :authorize_admins
    rescue_from MayMay::Unauthorized, with: :not_authorized

    def authorize_admins
      authorize!(:access, :admin) && authorize!(:manage, :tickets)
    end

    def not_authorized
      redirect_to main_app.root_path, alert: t("flash.not_authorized")
    end
  end
end
