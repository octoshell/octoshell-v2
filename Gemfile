source "https://rubygems.org"
gem "rake"
gem "rails", "~> 5.0"
gem 'bootsnap'
gem 'listen'
platforms :jruby do
  gem "activerecord-jdbcpostgresql-adapter", "~> 1.3.21"
end
gem "pg", "~> 0.18", platform: :ruby
gem "responders"
gem "uglifier", ">= 1.3.0"
gem "sassc-rails"
gem "bootstrap_form"
gem 'rails_email_preview', '~> 2.0.6'
gem 'left_join'
gem 'traco'
gem 'lmtp', github: 'apaokin/ruby-lmtp', require: false
gem 'rubyzip', '>= 1.0.0', require: false
gem 'paper_trail'

gem 'therubyracer' # for execjs
gem 'i18n-js'
gem 'groupdate'
gem 'cancancan'

# security reasons
gem "nokogiri", ">= 1.10.4"
gem "mini_magick", ">= 4.9.4"


group :development do
  gem "annotate"
  gem "sqlite3"
  gem "letter_opener"
  gem "pry-rails"
  gem "rails-erd"
  gem 'railroady'
  gem "better_errors"
  gem 'rails_db'
  gem 'i18n-tasks', github: 'apaokin/i18n-tasks'
  gem 'minitest-reporters'
end

gem "sinatra", ">= 1.3.0", :require => nil

gem "mina" #, github: "zhum/mina", require: false
#gem "mina-rbenv-addons", require: false
#gem "mina-foreman", github: "mina-deploy/mina-foreman"
#gem "mina-foreman", github: "asabourin/mina-foreman", require: false
#gem "mina-rails"
#gem "mina-git"

#gem "rollbar"
#gem "airbrake"
gem "foreman"
gem "puma"
gem "face",           path: "engines/face"
gem "authentication", path: "engines/authentication"
gem "core",           path: "engines/core"
gem "support",        path: "engines/support"
gem "sessions",       path: "engines/sessions"
gem "statistics",     path: "engines/statistics"
gem "wiki",           path: "engines/wiki"
gem "wikiplus",       path: "engines/wikiplus"
gem "announcements",  path: "engines/announcements"
gem "jobstat",        path: 'engines/jobstat'
gem "comments",       path: 'engines/comments'
gem "pack",           path: "engines/pack"
gem "hardware",       path: "engines/hardware"
gem "reports",       path: "engines/reports"
gem "api",            path: "engines/api"

gem "jquery-rails"
gem "jquery-ui-rails"
gem "jquery-tablesorter"

gem "config", github: 'railsconfig/config'
gem "decorators", "~> 1.0.0"
gem 'active_record_union'
gem "whenever"

group :test, :development do
  gem "factory_bot_rails"
end

group :test do
  gem "letter_opener"
  gem "rspec-rails"
  gem "activerecord-import", ">= 0.2.0"
  gem 'selenium-webdriver'
  gem "rspec-sidekiq"
  gem 'shoulda-matchers', '~> 4.0'
  # gem "test_after_commit"
  gem "database_cleaner"
  # gem "factory_bot_rails"
  gem "capybara"
  gem "phantomjs", github: "colszowka/phantomjs-gem"
  gem "codeclimate-test-reporter", require: false
end
