$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "hardware2/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "hardware2"
  s.version     = Hardware2::VERSION
  s.authors     = ["Andrey Paokin"]
  s.email       = ["andrejpaokin@yandex.ru"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Hardware2."
  s.description = "TODO: Description of Hardware2."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.10"

  s.add_development_dependency "sqlite3"
end
