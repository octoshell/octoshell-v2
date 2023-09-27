$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "support/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "support"
  s.version     = Support::VERSION
  s.authors     = ["Dmitry Koprov"]
  s.email       = ["dmitry.koprov@gmail.com"]
  s.homepage    = "https://github.com/octoshell/octoshell-v2"
  s.summary     = "An for users support in octoshell"
  s.description = "Provides fuctionality of the helpdesk for octoshell users"
  s.license     = "MIT"
  s.platform = 'java' if RUBY_ENGINE == 'jruby'

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 5.0"

  # s.add_dependency "activerecord-jdbcpostgresql-adapter" if /java/.match(RUBY_PLATFORM)
  # s.add_dependency "pg", "~> 0.18" unless /java/.match(RUBY_PLATFORM)
  s.add_dependency "decorators"
#  s.add_dependency "state_machines-activerecord"
  s.add_dependency "aasm"
  s.add_dependency "slim"
  s.add_dependency "sidekiq"
  s.add_dependency "mime-types"

  # s.add_dependency "maymay"
  s.add_dependency "ransack", "2.1.1"
  s.add_dependency "kaminari"
  s.add_dependency "mini_magick", ">= 4.9.4"
  s.add_dependency "carrierwave"

  s.add_dependency "nokogiri", ">= 1.10.4"

  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "annotate"
  # s.add_development_dependency "sqlite3"
end
