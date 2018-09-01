module Support
  class Admin::ApplicationController < Support::ApplicationController
    layout "layouts/support/admin"

    before_filter :authorize_admins

    def authorize_admins
      authorize!(:access, :admin) && authorize!(:manage, :tickets)
    end
  end
end
