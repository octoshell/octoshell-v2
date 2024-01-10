module Jobstat
  class Worker
    include Sidekiq::Worker
    sidekiq_options retry: 2, queue: :job

    def perform(id)
      Core::BotLinksApiHelper.job_finished(id)
    end
  end
end
