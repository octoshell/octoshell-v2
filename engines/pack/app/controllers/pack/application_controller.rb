module Pack
  class ApplicationController < ActionController::Base
    include AuthMayMay
    layout 'layouts/pack/application'

    before_action do |controller|
    	@extra_css="pack/pack.css"
    end

  end
end
