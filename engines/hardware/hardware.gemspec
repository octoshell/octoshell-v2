$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "hardware/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "hardware"
  s.version     = Hardware::VERSION
  s.authors     = ["Andrei Paokin"]
  s.email       = ["andrejpaokin@yandex.ru"]
  s.homepage    = "https://github.com/octoshell/octoshell-v2"
  s.summary     = "A hardware description engine for octoshell"
  s.description = "A hardware description engine for octoshell"
  s.license     = "MIT"
  s.platform = 'java' if RUBY_ENGINE == 'jruby'
  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "slim"
  s.add_dependency "decorators"

  # s.add_dependency "bootstrap_form"

  s.add_dependency "jquery-ui-rails"
  s.add_dependency "aasm"
  s.add_dependency "maymay"
  s.add_dependency "ransack"
  s.add_dependency "kaminari"
  s.add_dependency "carrierwave"
  s.add_dependency "mime-types"
  s.add_development_dependency 'rspec-rails'
  s.add_development_dependency "annotate"
  s.add_dependency "rails", "~> 5.0"
end
