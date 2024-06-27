module Jobstat
  module Admin
    class ApplicationController < ActionController::Base
      protect_from_forgery with: :null_session
      layout "layouts/jobstat/admin"

      before_action :authorize_admins

      def authorize_admins
        authorize!(:access, :admin)
      end
    end
  end
end
