module Core
  class JobNotificationEvent < ApplicationRecord
    self.table_name = 'core_job_notification_events'

    belongs_to :job_notification,
               class_name: 'Core::JobNotification',
               foreign_key: 'core_job_notification_id'

    belongs_to :user

    belongs_to :core_project,
               class_name: 'Core::Project',
               foreign_key: 'core_project_id'

    belongs_to :perf_job, class_name: 'Perf::Job', optional: true

    scope :unprocessed, -> { where(processed: false) }
    scope :unprocessed_status, -> { where(status: "unprocessed") }
    scope :older_than, ->(minutes) { where("created_at <= ?", minutes.minutes.ago) }

    validates :core_job_notification_id, :user_id, :core_project_id, :perf_job_id, presence: true

    def mark_as_processed
      update(processed: true, processed_at: Time.current, status: "processed")
    end

    def self.mark_old_unprocessed_as_processed_for_user(user_id, minutes)
      transaction do
        events = unprocessed.older_than(minutes).where(user_id: user_id).lock

        event_ids = events.pluck(:id)

        events.update_all(processed: true, processed_at: Time.current, status: "processed")

        where(id: event_ids)
      end
    end
  end
end
