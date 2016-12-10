module Pack
  class Admin::ApplicationController < ActionController::Base
  	 layout "layouts/application"
    rescue_from MayMay::Unauthorized, with: :not_authorized
    before_action do |controller|
    	@extra_css="pack/pack.css"
    end
    def not_authorized
      redirect_to root_path, alert: t("flash.not_authorized")
  	end
  end
end
