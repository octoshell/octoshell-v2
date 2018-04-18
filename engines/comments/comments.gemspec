$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "comments/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "comments"
  s.version     = Comments::VERSION
  s.authors     = ["Andrey Paokin"]
  s.email       = ["andrejpaokin@yandex.ru"]
  s.homepage    = "https://github.com/octoshell/octoshell-v2"
  s.summary     = "A comments engine for octoshell"
  s.description = "A comments engine for octoshell"
  s.license     = "MIT"


  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 4.2.6"
  s.add_dependency 'active_record_union'
  s.add_dependency 'translit'

end
