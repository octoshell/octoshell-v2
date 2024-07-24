class Admin::UsersController < Admin::ApplicationController
  before_action :setup_default_filter, only: :index
  before_action :octo_authorize!, except: %i[show index id_finder]

  def find_similar
    @user = User.find(params[:id])
    @users = users(User.joins(:profile).where("users.id != ? AND (email = ? or CONCAT(last_name, ' ', first_name, ' ', middle_name) = ?)",
    @user.id, @user.email, @user.full_name).page(params[:page]))
  end

  def index
    respond_to do |format|
      format.html do
        @search = User.includes({employments:[:organization,:organization_department]}, :profile).ransack(params[:q])
        @users = @search.result(distinct: true).order(id: :desc)
        without_pagination(:users)
      end
      format.json do
        @users = User.finder(params[:q])
        render json: { records: @users.page(params[:page]).per(params[:per]),
                       total: @users.count }
      end
    end

  def id_finder
    authorize! :access, :admin
    respond_to do |format|
      format.json do
        @users = User.id_finder(params[:q])

        @user_hash = @users.page(params[:page]).per(params[:per])
                           .map { |p| { id: p.id, text: "#{p.id}|#{p.full_name}" } }
        render json: { records: @user_hash, total: @users.count }
      end
    end
  end


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
    #user.destroy!
    user.deleted_at = Time.now
    user.email = '-'
    #FIXME: add new state?
    #user.state = 'deleted'
    user.state = 'closed'
    user.save
    profile = user.profile
    profile.last_name= '-'
    profile.middle_name= '-'
    profile.first_name= '-'
    profile.save
    user.employments.each{|e|
      e.positions.delete_all
    }
    redirect_to admin_users_path
  end

private

  def users(relation)
    relation.preload([ :profile]).distinct
  end

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
