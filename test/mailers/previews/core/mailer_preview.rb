module Core
    class MailerPreview < ActionMailer::Preview
      def job_notification
        # rails/mailers/core/mailer/job_notification
        log = Core::JobNotificationEventLog.first
        user = log.user
        Core::Mailer.job_notification(user.id, log.id)
      end
    end
  end
