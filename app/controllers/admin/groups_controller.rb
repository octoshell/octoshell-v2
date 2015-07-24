class Admin::GroupsController < Admin::ApplicationController
  def index
    @groups = Group.all
  end

  def new
    @group = Group.new
  end

  def create
    @group = Group.new(group_params)
    if @group.save
      redirect_to [:edit, :admin, @group]
    else
      render :new
    end
  end

  def edit
    @group = Group.find(params[:id])
  end

  def update
    @group = Group.find(params[:id])
    @group.update_attributes(group_params)
    redirect_to admin_groups_path
  end

  def default
    Group.default!
    redirect_to admin_groups_path
  end

  private

  def group_params
    params.require(:group).permit(:name, abilities_attributes: [ :id, :available ])
  end
end
