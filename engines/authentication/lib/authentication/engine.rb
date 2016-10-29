require "sorcery"
require "slim"
require "sidekiq"
require "bootstrap_form"

module Authentication
  class Engine < ::Rails::Engine
    isolate_namespace Authentication

    config.generators do |g|
      g.test_framework      :rspec,        :fixture => false
      g.fixture_replacement :factory_girl, :dir => "spec/factories"
      g.assets false
      g.helper false
    end

    config.sorcery.submodules = [
      :user_activation,
      :remember_me,
      :reset_password,
      :session_timeout,
      :activity_logging
    ]


    config.sorcery.configure do |config|
      config.user_config do |user|
        user.reset_password_mailer = Authentication::Mailer
        user.user_activation_mailer = Authentication::Mailer

        user.downcase_username_before_authenticating = true
      end

      config.session_timeout = 2.weeks
      config.session_timeout_from_last_action = false

      config.user_class = "User"
    end
  end
end
