# coding: utf-8
class Admin::ApplicationController < ApplicationController
  include AuthMayMay
  before_filter :authorize_admins!

private

  def authorize_admins!
    authorize! :access, :admin
  end
end
