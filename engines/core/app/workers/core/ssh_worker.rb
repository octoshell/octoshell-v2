module Core
  class SshWorker
    include Sidekiq::Worker
    sidekiq_options queue: :default

    def perform(template, args)
      Core::ResourceControl.send(template, *args).deliver!
    end
  end
end
