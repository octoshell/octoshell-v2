module Jobstat
  class ApplicationController < ActionController::Base
    protect_from_forgery with: :exception
    layout "layouts/jobstat/admin"

    before_filter :authorize_admins

    def authorize_admins
      authorize!(:access, :admin)
    end
  end
end
