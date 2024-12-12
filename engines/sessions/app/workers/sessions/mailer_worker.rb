module Sessions
  class MailerWorker
    include Sidekiq::Worker
    sidekiq_options queue: :default

    def perform(template, args)
      Sessions::Mailer.send(template, *args).deliver!
    end
  end
end
