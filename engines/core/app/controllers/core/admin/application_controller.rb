module Core
  class Admin::ApplicationController < Core::ApplicationController
    before_filter :authorize_admins

    def authorize_admins
      authorize! :access, :admin
    end
  end
end
