if ENV["CI_RUN"]
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../config/environment", __FILE__)
require "rspec/rails"
require "rspec/autorun"
require "shoulda-matchers"

require "factory_girl_rails"
require "capybara/rspec"
require "capybara/poltergeist"
require "sidekiq/testing"
require "contexts/user_abilities"
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
    Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

  Dir[Rails.root.join("engines/pack/spec/support/**/*.rb")].each { |f| require f }
  Dir[Rails.root.join("engines/pack/spec/factories/**/*.rb")].each { |f| require f }
  config.treat_symbols_as_metadata_keys_with_true_values = true

  config.include FactoryGirl::Syntax::Methods
  #config.include Requests::Helpers, type: :feature
  config.use_transactional_fixtures = false
  config.order = "random"
  # Capybara.javascript_driver = :poltergeist

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
    
     
    ensure
     
    end
     puts "Seeding data"
      Seed.all
      Pack::Seed.all  

    
  end
end
 