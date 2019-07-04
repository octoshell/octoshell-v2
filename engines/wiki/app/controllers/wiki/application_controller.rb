module Wiki
  class ApplicationController < ::ApplicationController
    layout "layouts/application"


    before_filter :add_css

    def add_css
      @extra_css="wiki/wiki.css"
    end
  end
end
