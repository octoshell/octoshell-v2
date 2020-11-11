$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "sessions/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "sessions"
  s.version     = Sessions::VERSION
  s.authors     = ["Dmitry Koprov"]
  s.email       = ["dmitry.koprov@gmail.com"]
  s.homepage    = "https://github.com/octoshell/octoshell-v2"
  s.summary     = "An engine an annual sessions in octoshell"
  s.description = "Provides functionality for session periods for octoshell users"
  s.license     = "MIT"
  s.platform = 'java' if RUBY_ENGINE == 'jruby'

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 5.0"

  s.add_dependency "activerecord-jdbcpostgresql-adapter" if /java/.match(RUBY_PLATFORM)
  s.add_dependency "pg", "~> 0.18" unless /java/.match(RUBY_PLATFORM)
  # s.add_dependency "decorators", "~> 1.0.2"
#  s.add_dependency "state_machines-activerecord"
  s.add_dependency "aasm"
  s.add_dependency "slim"
  s.add_dependency "sidekiq"
  # s.add_dependency "maymay"
  s.add_dependency "ransack", "2.1.1"
  s.add_dependency "kaminari"
  s.add_dependency "carrierwave"

  s.add_dependency "nokogiri", ">= 1.10.4"
  s.add_dependency "mini_magick", ">= 4.9.4"

  s.test_files = Dir["spec/**/*"]

  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "annotate"
end
