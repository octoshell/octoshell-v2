module Pack
  class ApplicationController < ActionController::Base
  	 layout "layouts/application"
    rescue_from MayMay::Unauthorized, with: :not_authorized
    before_action do |controller|
    	@extra_css="pack/pack.css"
    end
    @per=20
    before_action :check_namespace
    def check_namespace
      @admin=false
    end
    def not_authorized
      redirect_to root_path, alert: t("flash.not_authorized")
  	end
  end
end
