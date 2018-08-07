module Core
  module Checkable
    extend ActiveSupport::Concern

    def create_ticket(current_user)
      return if checked
      Notificator.check(self, current_user)
    end
  end
end
