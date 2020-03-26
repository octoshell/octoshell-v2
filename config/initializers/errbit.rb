if ENV['ERRBIT_ENABLED'].to_s != ''
  Airbrake.configure do |config|
    config.host = ENV['ERRBIT_HOST']
    config.project_id = ENV['ERRBIT_ID'] # required, but any positive integer works
    config.project_key = ENV['ERRBIT_KEY']
    config.performance_stats = true

    # Uncomment for Rails apps
    config.environment = Rails.env
    config.ignore_environments = %w(development test)
  end
end
