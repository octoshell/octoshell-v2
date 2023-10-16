module Support
  class MailerWorker
    include Sidekiq::Worker
    sidekiq_options retry: 2, queue: :default

    def perform(template, args)
      Support::Mailer.send(template, *args).deliver!
    end
  end
end
