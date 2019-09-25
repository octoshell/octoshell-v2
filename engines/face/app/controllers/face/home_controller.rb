module Face
  class HomeController < Face::ApplicationController
    def show
      if current_user
        redirect_to admin_redirect_path
      end
    end
  end
end
