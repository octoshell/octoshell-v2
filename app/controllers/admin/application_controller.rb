# coding: utf-8
class Admin::ApplicationController < ApplicationController
  before_filter :require_login
  before_filter :authorize_admins!

private

  def authorize_admins!
    authorize! :access, :admin
  end
end
