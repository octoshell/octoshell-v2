class UsersController < ApplicationController
  before_action :require_login

  def index
    respond_to do |format|
      format.html do
        @users = User.order(created_at: :desc)
      end
      format.json do
        @users = User.finder(params[:q])
        if User.superadmins.include? current_user
          render json: { records: @users.page(params[:page]).per(params[:per]),
                         total: @users.count }
        else
          render json: { records: @users.page(params[:page]).per(params[:per])
                                        .map{ |u| { id: u.id,
                                                    text: u.full_name_with_cut_email }},
                         total: @users.count }
        end
      end
    end
  end

  def edit
  end

  def update
    if current_user.update(user_params)
      redirect_to profile_path, notice: t("flash.password_updated")
    else
      render :edit
    end
  end

  def login_as
    authorize! :manage, :users
    user = User.find(params[:id])
    session[:soul_id] = current_user.id
    session[:soul_location] = request.env["HTTP_REFERER"]
    auto_login(user)
    redirect_to root_path
  end

  def return_to_self
    auto_login(User.find(session.delete(:soul_id)))
    redirect_to session[:soul_location].present? ? session[:soul_location] : root_path
  end

  def unblock_emails
    current_user.update!(block_emails: false)
    redirect_back_or_to(root_url, notice: t('.you_unblocked_email'))
  end


  private

  def user_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
