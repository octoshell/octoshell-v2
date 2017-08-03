if ENV["CI_RUN"]
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../config/environment", __FILE__)
require "rspec/rails"
require "rspec/autorun"
require "shoulda-matchers"
require "database_cleaner"
require "factory_girl_rails"
require "capybara/rspec"
require "capybara/poltergeist"
require "sidekiq/testing"
require "contexts/user_abilities"
require 'capybara/poltergeist'
require "common_helper"
  Sidekiq::Testing.inline!
# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.


# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

RSpec.configure do |config|

  config.include Sorcery::TestHelpers::Rails::Controller, type: :controller
  config.include Sorcery::TestHelpers::Rails::Integration, type: :feature
  config.include  Pack::Engine.routes.url_helpers

  # ## Mock Framework
  # config.mock_with :rr

  config.treat_symbols_as_metadata_keys_with_true_values = true

  
  # Capybara.javascript_driver = :webkit

  config.include FactoryGirl::Syntax::Methods
  Capybara.default_max_wait_time = 60
  #config.include Requests::Helpers, type: :feature
  config.use_transactional_fixtures = false
  config.order = "random"
  # Capybara.javascript_driver = :poltergeist
  Capybara.register_driver :poltergeist_debug do |app|
    Capybara::Poltergeist::Driver.new(app, :inspector => true)
  end

# Capybara.javascript_driver = :poltergeist
  Capybara.javascript_driver = :poltergeist_debug
  # Capybara.register_driver :poltergeist do |app|
  #   Capybara::Poltergeist::Driver.new(app,
  #     phantomjs: Phantomjs.path,
  #     inspector: false,
  #     phantomjs_logger: nil,
  #     timeout: 60
  #   )
  # end


  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false
  config.include PackHelpers

  config.before(:each) do


    Sidekiq::Worker.clear_all
  end
  
  config.before(:suite) do
    begin

      DatabaseCleaner.strategy = :truncation
      DatabaseCleaner.clean_with :truncation

      DatabaseCleaner.start
      FactoryGirl.lint

      
    ensure
      DatabaseCleaner.clean
    end
     puts "Seeding data"
      Seed.all
      Pack::Seed.all  

    
  end
  config.around(:each) do |example|

    DatabaseCleaner.cleaning do 

      example.run
    
    end
    Seed.all
    Pack::Seed.all  
  end
end
 