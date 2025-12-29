module Announcements
  class MailerWorker
    include Sidekiq::Worker
    sidekiq_options queue: :default

    def perform(template, args)
      Announcements::Mailer.send(template, *args).deliver!
    end
  end
end
