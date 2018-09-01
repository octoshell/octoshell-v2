module Sessions
  class ApplicationController < ActionController::Base
    include AuthMayMay
    layout "layouts/application"

  end
end
