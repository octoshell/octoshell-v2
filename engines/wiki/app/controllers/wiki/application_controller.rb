module Wiki
  class ApplicationController < ::ApplicationController
    #ActionController::Base
    #
    layout "layouts/application"


    before_action :add_css #, :journal_user
    before_action :require_login

    def add_css
      @extra_css="wiki/wiki.css"
    end
  end
end
