$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "cloud_computing/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "cloud_computing"
  spec.version     = CloudComputing::VERSION
  spec.authors     = ["Andrei Paokin"]
  spec.email       = ["andrejpaokin@yandex.ru"]
  spec.homepage    = "https://github.com/octoshell/octoshell-v2"
  spec.summary     = "Cloud computing engine for the Octoshell HPC management system"
  spec.description = "Cloud computing engine for the Octoshell HPC management system"
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", "~> 5.2.3"
  spec.add_dependency "slim"
  spec.add_dependency "aasm"
  spec.add_dependency "sidekiq"
  # s.add_dependency "maymay"
  spec.add_dependency "ransack", "2.1.1"
  spec.add_dependency "kaminari"
  spec.add_dependency "carrierwave"
  spec.add_dependency "mime-types"
  spec.add_dependency 'awesome_nested_set'
  spec.add_dependency 'xmlrpc'

  spec.add_development_dependency 'rspec-rails'
  # spec.add_development_dependency 'factory_girl_rails'
  spec.test_files = Dir["spec/**/*"]
  # spec.add_dependency "pg", "~> 0.18", platform: :ruby

  spec.add_development_dependency "annotate"

  spec.add_development_dependency "sqlite3"
end
