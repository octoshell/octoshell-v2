class Authentication::ActivationsController < Authentication::ApplicationController
  before_filter :logout

  def new
  end

  def create
    @user = User.find_by_email(params[:email].downcase)
    if @user && @user.activation_pending?
      @user.send_activation_needed_email!
      redirect_to new_session_path, notice: t("authentication.flash.activation_instructions_are_sent")
    else
      flash_message :alert, (@user ?
                             t("authentication.flash.user_is_already_activated") :
                             t("authentication.flash.user_is_not_registered"))
      render :new
    end
  end
end
