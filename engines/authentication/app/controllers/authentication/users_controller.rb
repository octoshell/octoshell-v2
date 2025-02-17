require 'json'
class Authentication::UsersController < Authentication::ApplicationController
  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user] ? user_params : {})
    @user.language = session[:locale]
    if !params[:cond] || cond_params[:cond_accepted].to_i != 1
      flash_now_message :notice, t("authentication.flash.conditions_must_be_accepted")
      @errors = true
    end

    if params['smart-token']
      if captcha_valid?
        session[:captcha_valid] = 't'
      else
        @errors = true
        flash_now_message :notice, t("authentication.flash.pass_captcha")
      end
    end

    if !@errors && @user.save
      redirect_to confirmation_users_path(email: @user.email)
    else
      render :new
    end
  end

  def activate
    @user = User.load_from_activation_token(params[:token])
    if @user
      @user.activate!
      @user.save
      auto_login @user
      flash_message :notice, t("authentication.flash.user_is_activated")
    else
      flash_message :notice, t("authentication.flash.user_is_not_registered")
    end

    redirect_back_or_to(root_url)
  end

  def confirmation
  end

  private

  def captcha_valid?
    uri = URI('https://smartcaptcha.yandexcloud.net/validate')
    uri.query = URI.encode_www_form(secret: Rails.application.secrets.yandex_captcha[:server_key],
                                    token: params['smart-token'],
                                    ip: request.remote_ip)
    res = Net::HTTP.get_response(uri)
    return true unless res.is_a?(Net::HTTPSuccess)

    JSON.parse(res.body)['status'] == 'ok'
  end

  def cond_params
    params.require(:cond).permit(:cond_accepted)
  end

  def user_params
    p=params.require(:user).permit(:email, :password, :password_confirmation)
    p[:email]=p[:email].to_s.downcase
    p
  end
end
