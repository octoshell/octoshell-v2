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

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)

RSpec.configure do |config|
  # ## Mock Framework
  # config.mock_with :rr

  config.treat_symbols_as_metadata_keys_with_true_values = true

  config.include FactoryGirl::Syntax::Methods
  config.include Requests::Helpers, type: :feature
  config.use_transactional_fixtures = true
  config.order = "random"

  Capybara.javascript_driver = :poltergeist

  Capybara.register_driver :poltergeist do |app|
    Capybara::Poltergeist::Driver.new(app,
      phantomjs: Phantomjs.path,
      inspector: false,
      phantomjs_logger: nil,
      timeout: 60
    )
  end

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  DatabaseCleaner.strategy = :transaction
  DatabaseCleaner.clean_with :truncation

  config.before(:suite) do
    begin
      DatabaseCleaner.start
      FactoryGirl.lint
    ensure
      DatabaseCleaner.clean
    end

    puts "Seeding data"
    Seed.all
  end
end
