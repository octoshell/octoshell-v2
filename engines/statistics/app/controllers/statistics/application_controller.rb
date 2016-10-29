module Statistics
  class ApplicationController < ActionController::Base
    layout "layouts/statistics/admin"

    before_filter :authorize_admins

    def authorize_admins
      authorize!(:access, :admin)
    end
  end
end
