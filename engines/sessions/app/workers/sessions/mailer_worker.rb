module Sessions
  class MailerWorker
    include Sidekiq::Worker
    sidekiq_options retry: 2, queue: :sessions_mailer

    def perform(template, args)
      Sessions::Mailer.send(template, *args).deliver!
    end
  end
end
