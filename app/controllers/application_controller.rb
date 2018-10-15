class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  before_filter :just_test

  def just_test
    logger.info "user=#{current_user ? current_user : 'none'}"
  end
end
