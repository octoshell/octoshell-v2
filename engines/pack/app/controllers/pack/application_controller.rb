module Pack
  class ApplicationController < ActionController::Base
    layout 'layouts/pack/application'
    rescue_from MayMay::Unauthorized, with: :not_authorized
    before_filter :require_login

    before_action do |controller|
    	@extra_css="pack/pack.css"
    end

    def not_authorized
      redirect_to root_path, alert: t("flash.not_authorized")
  	end
    def not_authenticated
      redirect_to main_app.root_path, alert: t("flash.not_logged_in")
    end
  end
end
