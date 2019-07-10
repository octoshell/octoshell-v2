Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  config.octo_feedback_host = 'http://graphit.parallel.ru:8123'
  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  #config.active_record.raise_in_transactional_callbacks = true

  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  # Run rails dev:cache to toggle caching.
  if Rails.root.join('tmp', 'caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => "public, max-age=#{2.days.to_i}"
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Store uploaded files on the local file system (see config/storage.yml for options)
  config.active_storage.service = :local

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.delivery_method = :letter_opener
  config.base_host = "localhost"
  config.action_mailer.default_options = { from: "info@localhost" }
  config.action_mailer.default_url_options = { host: "localhost:9000" }
  config.serve_static_files = true
  # config.assets.compile = true

  # Compress JavaScripts and CSS.
  # config.assets.js_compressor = Uglifier.new(harmony: true)


  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log
  config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'
  config.middleware.insert(0, Rack::Sendfile, config.action_dispatch.x_sendfile_header)

  config.logger = Logger.new(config.paths['log'].first, 'weekly', 5.megabytes)
  config.logger.level = Logger::DEBUG
  config.log_tags = [:remote_ip, lambda { |req| Time.now}] #, lambda { |req| req.session.inspect}]
  config.colorize_logging = true

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Highlight code that triggered database queries in logs.
  config.active_record.verbose_query_logs = true

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  config.assets.js_compressor = Uglifier.new(harmony: true)
  config.assets.css_compressor = :sass

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  config.i18n.fallbacks = [I18n.default_locale]
end
