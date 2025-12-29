module Core
  class MailerWorker
    include Sidekiq::Worker
    sidekiq_options queue: :default

    def perform(template, args)
      Core::Mailer.send(template, *args).deliver!
    end
  end
end
