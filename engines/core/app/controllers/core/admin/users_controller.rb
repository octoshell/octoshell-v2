module Core
  class Admin::UsersController < Admin::ApplicationController
    def index
      @users = User.joins(:accounts).distinct.order(:id)
    end

    def block
      user = User.find(params[:id])
      user.block!
      user.save

      redirect_to admin_users_path
    end

    def reactivate
      user = User.find(params[:id])
      user.reactivate!
      user.save

      redirect_to admin_users_path
    end
  end
end
