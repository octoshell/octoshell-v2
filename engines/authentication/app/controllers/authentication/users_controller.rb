class Authentication::UsersController < Authentication::ApplicationController
  def new
    @user = User.new
  end

  def create
    if cond_params[:cond_accepted].to_i!=1
      flash[:notice] = t("authentication.flash.conditions_must_be_accepted")
      redirect_back_or_to(root_url)
    else
      @user = User.new(user_params)
      @user.language = session[:locale]
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
  def cond_params
    params.require(:cond).permit(:cond_accepted)
  end

  def user_params
    p=params.require(:user).permit(:email, :password, :password_confirmation)
    p[:email]=p[:email].to_s.downcase
    p
  end
end
