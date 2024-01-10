module Sessions
  class ValidatorWorker
    include Sidekiq::Worker
    sidekiq_options queue: :low

    def perform(session_id)
      session = Sessions::Session.find(session_id)
      session.validate_reports_and_surveys
    end
  end
end
