class Authentication::UsersController < Authentication::ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to confirmation_users_path(email: @user.email)
    else
      render :new
    end
  end

  def activate
    @user = User.load_from_activation_token(params[:token])
    if @user
      @user.activate!
      auto_login @user
      flash[:notice] = t("authentication.flash.user_is_activated")
    else
      flash[:notice] = t("authentication.flash.user_is_not_registered")
    end

    redirect_back_or_to(root_url)
  end

  def confirmation
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :password_confirmation)
  end
end
