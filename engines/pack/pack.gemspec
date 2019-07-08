$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "pack/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "pack"
  s.version     = Pack::VERSION
  s.authors     = ["Andrei Paokin"]
  s.email       = ["andrejpaokin@yandex.ru"]
  s.homepage    = "https://github.com/octoshell/octoshell-v2"
  s.summary     = "A pack engine for octoshell"
  s.description = "A pack engine for octoshell"
  s.license     = "MIT"
  s.platform = 'java' if RUBY_ENGINE == 'jruby'

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.2"

  # s.add_dependency "activerecord-jdbcpostgresql-adapter"
  s.add_dependency "slim"
  s.add_dependency "decorators"

  # s.add_dependency "bootstrap_form"

  s.add_dependency "jquery-ui-rails"
  s.add_dependency "aasm"
  s.add_dependency "nested_form"
  s.add_dependency "sidekiq"
  s.add_dependency "maymay"
  s.add_dependency "ransack"
  s.add_dependency "kaminari"
  s.add_dependency "carrierwave"
  s.add_dependency "mime-types"
  s.add_dependency 'active_record_union'
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency 'capybara'
  s.add_development_dependency 'factory_girl_rails'
  s.test_files = Dir["spec/**/*"]

  s.add_development_dependency "annotate"
end
