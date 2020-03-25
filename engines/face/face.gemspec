$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "face/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "face"
  s.version     = Face::VERSION
  s.authors     = ["Dmitry Koprov"]
  s.email       = ["dmitry.koprov@gmail.com"]
  s.homepage    = "https://github.com/octoshell/octoshell-v2"
  s.summary     = "An engine for octoshell front-end customization"
  s.description = "Does all settings for an octoshell front-end presentation"
  s.license     = "MIT"
  s.platform = 'java' if RUBY_ENGINE == 'jruby'

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 5.0"
  s.add_dependency "activerecord-jdbcpostgresql-adapter" if /java/.match(RUBY_PLATFORM)
  s.add_dependency "pg", "~> 0.18" unless /java/.match(RUBY_PLATFORM)
  s.add_dependency "bootstrap_form", "< 4"
  s.add_dependency "nested_form"
  s.add_dependency "slim"
  s.add_dependency "russian"
  s.add_dependency "therubyrhino"
  s.add_dependency "sassc-rails"
  s.add_dependency "coffee-rails"
  s.add_dependency "jquery-rails"
  s.add_dependency "select2-rails"
  s.add_dependency "underscore-rails"
  s.add_dependency "bootstrap-datepicker-rails"
  s.add_dependency 'momentjs-rails', '>= 2.9.0'
  s.add_dependency 'bootstrap3-datetimepicker-rails', '~> 4.17.47'
  s.add_dependency "commonmarker"
  s.add_dependency "rails-jquery-autocomplete"
  s.add_dependency "jquery-fileupload-rails"

  s.add_dependency "nokogiri", ">= 1.10.4"
  s.add_dependency "mini_magick", ">= 4.9.4"


  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "capybara"
  s.add_development_dependency "annotate"
end
