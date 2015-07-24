$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "statistics/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "statistics"
  s.version     = Statistics::VERSION
  s.authors     = ["Dmitry Koprov"]
  s.email       = ["dmitry.koprov@evrone.ru"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Statistics."
  s.description = "TODO: Description of Statistics."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 4.1.4"

  s.add_dependency "activerecord-jdbcpostgresql-adapter"
  s.add_dependency "slim"
  s.add_dependency "sidekiq"
  s.add_dependency "maymay"
  s.add_dependency "ransack"
  s.add_dependency "kaminari"
end
