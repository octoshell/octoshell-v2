module AuthMayMay
  extend ActiveSupport::Concern
  def not_authenticated
    redirect_to main_app.root_path, alert: t("flash.not_logged_in")
  end

  def not_authorized
    redirect_to main_app.root_path, alert: t("flash.not_authorized")
  end

  included do
    rescue_from MayMay::Unauthorized, with: :not_authorized
    before_action :require_login
  end
end
