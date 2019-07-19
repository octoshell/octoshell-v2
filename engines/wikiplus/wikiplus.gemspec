$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "wikiplus/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "wikiplus"
  s.version     = Wikiplus::VERSION
  s.authors     = ["Ukhin Sergey", "Zhumatiy Sergey"]
  s.email       = ["ser191097@gmail.com","serg@parallel.ru"]
  s.homepage    = "https://github.com/octoshell/octoshell-v2"
  s.summary     = "A wikiplus engine for octoshell"
  s.description = "Provides a wikiplus engine with markdown support"
  s.license     = "MIT"
  s.platform = 'java' if RUBY_ENGINE == 'jruby'

  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 4.2"
  s.add_dependency "activerecord-jdbcpostgresql-adapter" if /java/.match(RUBY_PLATFORM)
  s.add_dependency "pg", "~> 0.18" unless /java/.match(RUBY_PLATFORM)
  s.add_dependency "slim"
  #  s.add_dependency "activerecord-jdbcpostgresql-adapter"
  # s.add_dependency "bootstrap_form"
  s.add_dependency "maymay"
  s.add_dependency "sqlite3", "~> 1.3.6"
  s.add_dependency "carrierwave"

  s.test_files = Dir["spec/**/*"]
end
