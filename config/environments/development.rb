Octoshell::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.active_record.raise_in_transactional_callbacks = true

  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = true

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false
  config.action_mailer.delivery_method = :letter_opener
  config.base_host = "localhost"
  config.action_mailer.default_options = { from: "info@localhost" }
  config.action_mailer.default_url_options = { host: "localhost:3000" }
  config.serve_static_files = false

  # Compress JavaScripts and CSS.
  # config.assets.js_compressor = Uglifier.new(harmony: true)


  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log
  config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect'
  config.middleware.insert(0, Rack::Sendfile, config.action_dispatch.x_sendfile_header)

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true
end
