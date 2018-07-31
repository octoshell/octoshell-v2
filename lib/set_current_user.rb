module SetCurrentUser
  extend ActiveSupport::Concern
  def set_current_user
    Thread.current[:user] = current_user
  end
  included do
    before_action :set_current_user
  end
end
ActionController::Base.include SetCurrentUser
