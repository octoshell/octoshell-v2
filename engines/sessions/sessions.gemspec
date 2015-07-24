$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "sessions/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "sessions"
  s.version     = Sessions::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Sessions."
  s.description = "TODO: Description of Sessions."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.1.4"

  s.add_dependency "activerecord-jdbcpostgresql-adapter"
  s.add_dependency "decorators", "~> 1.0.2"
  s.add_dependency "state_machine"
  s.add_dependency "slim"
  s.add_dependency "sidekiq"
  s.add_dependency "maymay"
  s.add_dependency "ransack"
  s.add_dependency "kaminari"
  s.add_dependency "mini_magick"
  s.add_dependency "carrierwave"

  s.test_files = Dir["spec/**/*"]

  s.add_development_dependency "rspec-rails"
end
