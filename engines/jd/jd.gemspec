$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "jd/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "jd"
  s.version     = Jd::VERSION
  s.authors     = ["Pavel Shvets"]
  s.email       = ["shvets.pavel.srcc@gmail.com"]
  s.homepage    = "https://github.com/octoshell/octoshell-v2"
  s.summary     = "Integration with job jd service"
  s.description = "Integration with job jd service"
  s.license     = "MIT"

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 4.2"

  # s.add_development_dependency "activerecord-jdbcsqlite3-adapter"
end
