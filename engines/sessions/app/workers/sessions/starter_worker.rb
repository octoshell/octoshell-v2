module Sessions
  class StarterWorker
    include Sidekiq::Worker
    sidekiq_options queue: :low

    def perform(session_id)
      session = Sessions::Session.find(session_id)
      session.create_reports_and_users_surveys
    end
  end
end
