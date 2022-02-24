module Announcements
  class MailerWorker
    include Sidekiq::Worker
    sidekiq_options retry: 7, queue: :announcements_mailer

    def send_announcement(id)
      announcement = Announcement.find(id)
      announcement.announcement_recipient_ids.each do |recipient_id|
        Announcements::MailerWorker.perform_async(:announcement, recipient_id)
      end
    end

    def perform(template, args)
      if template.to_s == 'send_announcement'
        send_announcement(args)
      else
        Announcements::Mailer.send(template, *args).deliver!
      end
    end
  end
end
