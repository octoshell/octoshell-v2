module Authentication
  class MailerWorker
    include Sidekiq::Worker
    sidekiq_options queue: :default

    def perform(template, args)
      Authentication::Mailer.send(template, *args).deliver!
    end
  end
end
