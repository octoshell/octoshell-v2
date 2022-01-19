require 'uri'
require_relative 'boot'

require 'rails/all'
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Octoshell
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.0

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = "Moscow"

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.locale = :ru
    config.i18n.default_locale = :ru
    config.assets.initialize_on_precompile = false
    config.jd_systems = {}

    config.cache_store = :memory_store, { size: 128.megabytes, expires_in: 600 }
    config.active_record.belongs_to_required_by_default = false
    #config.active_record.raise_in_transactional_callbacks = true
    config.action_controller.include_all_helpers = true
    # RAILS5
    #config.action_controller.per_form_csrf_tokens = true
    #config.action_controller.forgery_protection_origin_check = true
  end
end
