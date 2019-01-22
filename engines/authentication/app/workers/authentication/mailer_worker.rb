module Authentication
  class MailerWorker
    include Sidekiq::Worker
    sidekiq_options retry: 2, queue: :auth_mailer

    def perform(template, args)
      Authentication::Mailer.send(template, *args).deliver!
    end
  end
end
