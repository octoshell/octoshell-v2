module Pack
  class ApplicationController < ::ApplicationController
    #ActionController::Base
#    include AuthMayMay
    layout 'layouts/pack/application'
    #layout "layouts/application"
    skip_before_action :verify_authenticity_token

    before_action do |controller|
      @extra_css=["pack/pack.css"]
    end

  end
end
