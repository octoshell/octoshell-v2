$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "reports/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "reports"
  s.version     = Reports::VERSION
  s.authors     = ["Andrei Paokin"]
  s.email       = ["andrejpaokin@yandex.ru"]
  s.homepage    = "https://github.com/octoshell/octoshell-v2"
  s.summary     = "A reports  engine for octoshell"
  s.description = "Universal report constructor"
  s.license     = "MIT"
  s.platform = 'java' if RUBY_ENGINE == 'jruby'
  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]



  # s.add_dependency "rails", "~> 5.0"

end
