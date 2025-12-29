module Support
  class MailerWorker
    include Sidekiq::Worker
    sidekiq_options queue: :default

    def perform(template, args)
      Support::Mailer.send(template, *args).deliver!
    end
  end
end
