class Authentication::PasswordsController < Authentication::ApplicationController
  def new
  end

  def create
    @user = User.find_by_email(params[:email])
    if @user && @user.activated?
      @user.deliver_reset_password_instructions!
      redirect_to new_session_path, notice: t("authentication.flash.password_reset_instructions_are_sent")
    else
      flash[:alert] = if @user
                        t("authentication.flash.user_is_not_activated")
                      else
                        t("authentication.flash.user_is_not_registered")
                      end
      render :new
    end
  end

  def change
    if @user = User.load_from_reset_password_token(params[:token])
      auto_login @user
    else
      flash[:notice] = t("authentication.flash.user_is_not_registered")
    end

    redirect_to main_app.root_path
  end
end
