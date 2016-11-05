module Pack
  class ApplicationController < ActionController::Base
  	 layout "layouts/application"
    rescue_from MayMay::Unauthorized, with: :not_authorized

  end
end
