module Core
  module Checkable
    extend ActiveSupport::Concern

    def create_ticket(current_user)

      return unless Octoface.role_class?(:support, 'Notificator')

      return if checked

      Notificator.check(self, current_user)
    end
  end
end
