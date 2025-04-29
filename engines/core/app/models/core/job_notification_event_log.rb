module Core
  class JobNotificationEventLog < ApplicationRecord
    self.table_name = 'core_job_notification_event_logs'

    belongs_to :user

    validates :user_id, :events_count, presence: true

    def self.find_for_period(user, start_period, end_period)
      where(user: user, start_period: start_period, end_period: end_period).first
    end
  end
end
