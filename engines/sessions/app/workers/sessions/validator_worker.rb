module Sessions
  class ValidatorWorker
    include Sidekiq::Worker
    sidekiq_options queue: :sessions_validator

    def perform(session_id)
      session = Sessions::Session.find(session_id)
      session.validate_reports_and_surveys
    end
  end
end
