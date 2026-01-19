module Wikiplus
  class ApplicationController < ::ApplicationController
    layout "layouts/application"
    before_action :require_login
    before_action do
      @extra_js = 'wikiplus/application'
      @extra_css = 'wikiplus/application'
    end

  end
end
