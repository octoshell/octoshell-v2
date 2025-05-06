module Core
  class MailJobNotificationWorker
    include Sidekiq::Worker
    sidekiq_options retry: 3

    def perform(user_id, params)
      user = User.find(user_id)
      Core::Mailer.job_notification(user.id, params).deliver_now
    rescue => e
      Rails.logger.error "MailNotificationWorker error for user #{user_id}: #{e.message}"
      raise e
    end
  end
end
