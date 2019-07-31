module AuthMayMay
  extend ActiveSupport::Concern

  included do
    before_action :require_login
  end
end
