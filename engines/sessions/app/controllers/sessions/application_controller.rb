module Sessions
  class ApplicationController < ActionController::Base
    include AuthMayMay
    layout "layouts/application"
    helper Face::ApplicationHelper

  end
end
