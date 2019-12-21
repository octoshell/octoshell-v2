module Core
  class Admin::UsersController < Admin::ApplicationController
    def index
      @users = User.joins(:accounts).distinct.order(:id)
    end

    def owners_finder
      @users = Core.user_class.owners_finder(params[:q])
      render json: { records: @users.page(params[:page]).per(params[:per]),
                     total: @users.count }
    end

    def with_owned_projects_finder
      @users = Core.user_class.with_owned_projects_finder(params[:q])
      puts @users.count.to_s.red
      puts @users.page(params[:page]).per(params[:per]).to_sql.inspect.red
      puts @users.page(params[:page]).per(params[:per]).to_a.inspect.red
      render json: { records: @users.page(params[:page]).per(params[:per]),
                     total: @users.count }
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
