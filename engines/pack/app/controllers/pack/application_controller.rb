module Pack
  class ApplicationController < ::ApplicationController
    #ActionController::Base
#    include AuthMayMay
#    #layout 'layouts/pack/application'
    layout "layouts/application"

    before_action do |controller|
    	@extra_css="pack/pack.css"
    end

  end
end
