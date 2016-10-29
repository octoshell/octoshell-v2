class Admin::UsersController < Admin::ApplicationController
  before_filter :setup_default_filter, only: :index
  before_filter :check_authorization, except: :show

  def index
    @search = User.includes(:employments).search(params[:q])
    @users = @search.result(distinct: true).order(id: :desc).page(params[:page])
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update(user_params)
      redirect_to [:admin, @user]
    else
      render :edit
    end
  end

  def block_access
    @user = User.find(params[:id])
    @user.block!
    redirect_to [:admin, @user]
  end

  def unblock_access
    @user = User.find(params[:id])
    @user.reactivate!
    redirect_to [:admin, @user]
  end

  def destroy
    user = User.find(params[:id])
    user.destroy!
    redirect_to admin_users_path
  end

private

  def check_authorization
    authorize! :manage, :users
  end

  def user_params
    params.require(:user).permit(group_ids: [])
  end

  def setup_default_filter
    params[:q] ||= {
      user_groups_group_name_in: ['authorized']
    }
    params[:q][:meta_sort] ||= 'id.desc'
  end
end
