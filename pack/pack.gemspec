$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "pack/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "pack"
  s.version     = Pack::VERSION
  s.authors     = ["Paokin"]
  s.email       = ["zzz@zzz.com"]
  s.homepage    = "TODO"
  s.summary     = "TODO: Summary of Pack."
  s.description = "TODO: Description of Pack."
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2.6"

  s.add_development_dependency "activerecord-jdbcsqlite3-adapter"
end
