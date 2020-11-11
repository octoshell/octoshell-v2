$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "core/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "core"
  s.version     = Core::VERSION
  s.authors     = ["Dmitry Koprov"]
  s.email       = ["dmitry.koprov@gmail.com"]
  s.homepage    = "https://github.com/octoshell/octoshell-v2"
  s.summary     = "A core engine for octoshell"
  s.description = "Basic logic and bisuness models for an octoshell"
  s.license     = "MIT"
  s.platform = 'java' if RUBY_ENGINE == 'jruby'
  s.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  s.add_dependency "rails", "~> 5.0"
  s.add_dependency "activerecord-jdbcpostgresql-adapter" if /java/.match(RUBY_PLATFORM)
  s.add_dependency "pg", "~> 0.18" unless /java/.match(RUBY_PLATFORM)
  # s.add_dependency "decorators", "~> 1.0.2"
#  s.add_dependency "state_machines-activerecord"
  s.add_dependency "aasm"
  s.add_dependency "slim"
  s.add_dependency "sidekiq"
  s.add_dependency "sidekiq-failures"
  s.add_dependency "sshkey"
  s.add_dependency "net-ssh"
  s.add_dependency "net-scp"
  # s.add_dependency "maymay"
  s.add_dependency "ransack", "2.1.1"
  s.add_dependency "kaminari"
  s.add_dependency "clbustos-rtf"
  s.add_dependency "carrierwave"
  s.add_dependency "roo"
  s.add_dependency "colorize"
  s.add_dependency 'write_xlsx'

  s.add_dependency "nokogiri", ">= 1.10.4"
  s.add_dependency "mini_magick", ">= 4.9.4"


  s.test_files = Dir["spec/**/*"]

  s.add_development_dependency "rspec-rails"
  s.add_development_dependency "annotate"
end
