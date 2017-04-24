module Pack
  class PackWorker
    include Sidekiq::Worker
    sidekiq_options retry: 2, queue: :pack_worker

    def perform(template, args)
      try(template, *args) || Pack::Mailer.send(template, *args).deliver!
    end
  end
end
