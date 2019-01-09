module Jobstat
  class AdminApplicationController < ActionController::Base
    protect_from_forgery with: :null_session
    layout "layouts/jobstat/admin"

    before_filter :authorize_admins

    def authorize_admins
      authorize!(:access, :admin)
    end
  end
end
