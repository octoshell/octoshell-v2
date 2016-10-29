class ProfilesController < ApplicationController
  before_filter :require_login

  def show
    @profile = current_user.profile
  end

  def edit
    @profile = current_user.profile
  end

  def update
    profile = current_user.profile
    if profile.update(profile_params)
      redirect_to profile_path, note: t("flash.profile_updated")
    else
      render :edit
    end
  end

  private

  def profile_params
    params.require(:profile).permit(:first_name, :middle_name, :last_name, :about,
                                   :receive_info_mails, :receive_special_mails)
  end
end
