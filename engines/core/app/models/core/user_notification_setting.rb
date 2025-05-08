module Core
  class UserNotificationSetting < ApplicationRecord
    self.table_name = 'core_user_notification_settings'

    belongs_to :user

    validates :user_id, presence: true, uniqueness: true
    validates :notification_batch_interval, numericality: { only_integer: true, greater_than: 0 }

    def self.for_user(user)
      find_by(user: user) || create_with(
        notification_batch_interval: 5
      ).find_or_create_by!(user: user)
    end
  end
end
