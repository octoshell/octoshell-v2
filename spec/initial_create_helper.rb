if ENV["CI_RUN"]
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../config/environment", __FILE__)
require "rspec/rails"
require "rspec/autorun"
require 'shoulda-matchers'
require "database_cleaner"
require "factory_bot_rails"
require "capybara/rspec"
require "capybara/poltergeist"
require "sidekiq/testing"
require "contexts/user_abilities"
require "common_helper"
Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

Sidekiq::Testing.inline!
# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
# Checks for pending migrations before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.check_pending! if defined?(ActiveRecord::Migration)
RSpec.configure do |config|
  config.include Sorcery::TestHelpers::Rails::Controller, type: :controller
  config.include Sorcery::TestHelpers::Rails::Integration, type: :feature
  config.include PackHelpers
  config.include(Shoulda::Matchers::ActiveModel, type: :model)
  config.include(Shoulda::Matchers::ActiveRecord, type: :model)

  # ## Mock Framework
  # config.mock_with :rr
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.include FactoryBot::Syntax::Methods
  #config.include Requests::Helpers, type: :feature
  config.use_transactional_fixtures = true
  config.order = "random"
  config.infer_base_class_for_anonymous_controllers = false
  DatabaseCleaner.strategy = :transaction
  DatabaseCleaner.clean_with :truncation
  config.before(:each) do
    Sidekiq::Worker.clear_all
  end
  config.before(:suite) do
    begin
      Group.default!
      user = User.create!(email: "big_admin@octoshell.ru", password: "123456")
      Thread.current[:user] = user
      UserGroup.create!(user: user, group: Group.find_by!(name: "superadmins"))
      UserGroup.create!(user: user, group: Group.find_by!(name: "support"))
      country = Core::Country.create!(title_ru: 'Россия', title_en: 'Russia')
      country.cities.create!(title_ru: 'Москва', title_en: 'Moscow')
      DatabaseCleaner.start
      FactoryBot.lint
    ensure
      DatabaseCleaner.clean
    end
    puts "Seeding data"
    Seed.all
    Pack::Seed.all
  end
end
