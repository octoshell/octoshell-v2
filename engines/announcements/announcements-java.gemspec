$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "announcements/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "announcements"
  s.version     = Announcements::VERSION
  s.authors     = ["Dmitry Koprov"]
  s.email       = ["dmitry.koprov@gmail.com"]
  s.homepage    = "https://github.com/octoshell/octoshell-v2"
  s.summary     = "An engine for octoshell announcements"
  s.description = "Does all of the mass mailsending for an octoshell"
  s.platform    = "java"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]

  s.add_dependency "rails", "~> 4.2"

  s.add_dependency "activerecord-jdbcpostgresql-adapter"
  s.add_dependency "decorators", "~> 1.0.2"
  #s.add_dependency "state_machine"
  s.add_dependency "aasm"
  s.add_dependency "slim"
  s.add_dependency "sidekiq"
  s.add_dependency "maymay"
  s.add_dependency "ransack"
  s.add_dependency "kaminari"
  s.add_dependency "carrierwave"
  s.add_dependency "kramdown"

  s.test_files = Dir["spec/**/*"]
end
