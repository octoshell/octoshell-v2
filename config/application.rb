require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Octoshell
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.0

    config.time_zone = "Moscow"

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.locale = :ru
    config.i18n.default_locale = :ru
    config.assets.initialize_on_precompile = false
    config.jd_systems = {}
    config.octo_feedback_host = 'http://188.44.52.38:28082'
    config.octo_jd_host = 'http://188.44.52.38:28081'


    config.cache_store = :memory_store, { size: 128.megabytes, expires_in: 600 }
    config.active_record.belongs_to_required_by_default = false
    config.action_controller.include_all_helpers = true
    config.active_record.yaml_column_permitted_classes = [Symbol, Date, Time, ActiveSupport::TimeWithZone, ActiveSupport::TimeZone]

    config.factory_bot.definition_file_paths +=
           Dir.glob('engines/*/spec/factories') if defined?(FactoryBotRails)


    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
