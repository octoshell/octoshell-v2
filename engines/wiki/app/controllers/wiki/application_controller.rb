module Wiki
  class ApplicationController < ActionController::Base
    include AuthMayMay
    layout "layouts/application"


    before_action do |controller|
    	@extra_css="wiki/wiki.css"
    end

  end
end
