module Hardware
  class ApplicationController < ActionController::Base
    include AuthMayMay
    protect_from_forgery with: :exception
    layout 'layouts/hardware/application'
  end
end
