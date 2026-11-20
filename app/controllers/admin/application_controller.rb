class Admin::ApplicationController < ApplicationController
  before_action :require_login
  before_action :authorize_admins!

  private

  def authorize_admins!
    authorize! :access, :admin
  end
end
