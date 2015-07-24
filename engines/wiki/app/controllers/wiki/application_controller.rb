module Wiki
  class ApplicationController < ActionController::Base
    layout "layouts/application"

    rescue_from MayMay::Unauthorized, with: :not_authorized

    def not_authorized
      redirect_to root_path, alert: t("flash.not_authorized")
    end
  end
end
