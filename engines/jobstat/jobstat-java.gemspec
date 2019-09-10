$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "jobstat/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "jobstat"
  s.version     = Jobstat::VERSION
  s.authors     = ["Sergey Zhumatiy"]
  s.email       = ["serg@parallel.ru"]
  s.homepage    = "http://octoshell.ru"
  s.summary     = "Jobstat is a module for Octoshell. It holds stats data for user jobs etc."
  s.description = "Jobstat is a module for Octoshell. It holds stats data for user jobs etc."
  s.license     = "MIT"
  s.platform    = "java"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2"

  s.add_development_dependency "activerecord-jdbcsqlite3-adapter"
  s.add_dependency "activerecord-jdbcpostgresql-adapter"
  s.add_dependency "slim"
  s.add_dependency "sidekiq"
  s.add_dependency "maymay"
  s.add_dependency "ransack"
  s.add_dependency "kaminari"

  s.add_dependency "nokogiri", ">= 1.10.4"
  s.add_dependency "mini_magick", ">= 4.9.4"

  s.add_development_dependency "annotate"
end
