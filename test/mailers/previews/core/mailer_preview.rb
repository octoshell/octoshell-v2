module Core
  class MailerPreview < ActionMailer::Preview
    def job_notification
      # rails/mailers/core/mailer/job_notification

      event = Core::JobNotificationEvent.first
      return unless event

      user = event.user

      events = Core::JobNotificationEvent.where(user_id: user.id).order(created_at: :desc).limit(10)

      start_period = events.map(&:created_at).compact.min || Time.current
      end_period = events.map(&:created_at).compact.max || Time.current

      worker = Core::BatchProcessingWorker.new
      summary_data = worker.send(:prepare_summary, events)
      details = worker.send(:generate_details, events, summary_data)

      params = {
        events_count: events.count,
        summary_data: summary_data,
        details: details,
        start_period: start_period,
        end_period: end_period
      }

      Core::Mailer.job_notification(user.id, params)
    end
  end
end
