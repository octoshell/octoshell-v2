module Wikiplus
  class ApplicationController < ::ApplicationController
    layout "layouts/application"
    before_action :require_login

  end
end
