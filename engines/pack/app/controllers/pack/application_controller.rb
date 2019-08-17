module Pack
  class ApplicationController < ::ApplicationController
    before_action :require_login
    layout 'layouts/pack/application'
    before_action do |controller|
    	@extra_css="pack/pack.css"
    end

  end
end
