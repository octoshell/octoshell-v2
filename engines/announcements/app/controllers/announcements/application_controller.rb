module Announcements
  class ApplicationController < ActionController::Base
    layout "layouts/application"

    before_filter :require_login

    rescue_from MayMay::Unauthorized, with: :not_authorized

    def not_authenticated
      redirect_to main_app.root_path, alert: t("flash.not_logged_in")
    end

    def not_authorized
      redirect_to main_app.root_path, alert: t("flash.not_authorized")
    end
  end
end
