$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "api/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "api"
  s.version     = Api::VERSION
  s.authors     = ["Sergey Zhumatiy"]
  s.email       = ["serg@parallel.ru"]
  s.homepage    = "https://octoshell.ru"
  s.summary     = "Module to export public and private APIs for all modules via single entry"
  s.description = "Module to export public and private APIs for all modules via single entry"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.11.1"

  s.add_dependency "nokogiri", ">= 1.10.4"
  s.add_dependency "mini_magick", ">= 4.9.4"

  #s.add_development_dependency "sqlite3"
  s.add_development_dependency "annotate"
end
