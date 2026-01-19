class Admin::ApplicationController < ApplicationController
  before_action :authorize_admins!
  before_action :require_login

  private

  def authorize_admins!
    authorize! :access, :admin
  end
end
