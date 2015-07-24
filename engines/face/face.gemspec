$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "face/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "face"
  s.version     = Face::VERSION
  s.authors     = ["TODO: Your name"]
  s.email       = ["TODO: Your email"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Face."
  s.description = "TODO: Description of Face."

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.1.0"
  s.add_dependency "activerecord-jdbcpostgresql-adapter"
  s.add_dependency "bootstrap_form"
  s.add_dependency "nested_form"
  s.add_dependency "slim"
  s.add_dependency "russian"
  s.add_dependency "therubyrhino"
  s.add_dependency "sass-rails"
  s.add_dependency "coffee-rails"
  s.add_dependency "jquery-rails"
  s.add_dependency "select2-rails"
  s.add_dependency "underscore-rails"
  s.add_dependency "bootstrap-datepicker-rails"
  s.add_dependency "kramdown"

  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "capybara"
end
