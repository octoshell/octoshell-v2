module Face
  class HomeController < ApplicationController
    def show
      if current_user
        if User.superadmins.include? current_user
          redirect_to main_app.admin_users_path
        elsif User.experts.include? current_user
          redirect_to sessions.admin_reports_path
        elsif User.support.include? current_user
          redirect_to support.admin_tickets_path
        else
          redirect_to core.projects_path
        end
      end
    end
  end
end
