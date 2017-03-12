module Pack
  class Admin::ApplicationController < ActionController::Base
  	 layout "layouts/application"
     #layout "layouts/pack/application"
    
    rescue_from MayMay::Unauthorized, with: :not_authorized
    @per=20
    before_action do |controller|
    	@extra_css="pack/pack.css"
    end
     before_filter :check_abilities
    def not_authorized
      redirect_to root_path, alert: t("flash.not_authorized")
  	end
    def check_abilities
      @admin=true
      authorize! :manage, :packages
    end
  end
end
