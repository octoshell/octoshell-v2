class Authentication::UsersController < Authentication::ApplicationController
  def new
    @user = User.new
  end

  def create
    if user_params[:cond_accepted].to_i!=1
      flash[:notice] = t("authentication.flash.conditions_must_be_accepted")
      redirect_back
    else
      user_params.delete! :cond_accepted
      @user = User.new(user_params)
      if @user.save
        redirect_to confirmation_users_path(email: @user.email)
      else
        render :new
      end
    end
  end

  def activate
    @user = User.load_from_activation_token(params[:token])
    if @user
      @user.activate!
      @user.save
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
    params.require(:user).permit(:email, :password, :password_confirmationi, :cond_accepted)
    params[:email].downcase!
    params
  end
end
