source 'https://rubygems.org'
gem 'rails', '~> 8.0.0'
gem 'rake'
#-----------------------------------------
gem 'honeybadger'

gem 'airbrake' if ENV['AIRBRAKE'].to_s != ''
#-----------------------------------------
gem 'after_commit_everywhere' # , '~> 1.0'
gem 'bootsnap'
gem 'listen'
platforms :jruby do
  gem 'activerecord-jdbcpostgresql-adapter', '~> 1.3.21'
end
# gem "pg", "~> 0.18", platform: :ruby
gem 'pg'
gem 'responders'
gem 'uglifier', '>= 1.3.0'
# gem "sassc-rails"
gem 'bootstrap_form'
gem 'lmtp', github: 'apaokin/ruby-lmtp', require: false
gem 'paper_trail'
gem 'rails_email_preview' # , '~> 2.0.6'
gem 'rubyzip', '>= 1.0.0', require: false
gem 'traco'

gem 'cancancan'
gem 'connection_pool', '~> 2.4'
gem 'groupdate'
gem 'i18n-js'
gem 'ransack'
gem 'therubyracer' # for execjs
# gem 'mail', '2.7.1' # smtp localhost does not work in 2.8.1
# security reasons
gem 'mini_magick', '>= 4.9.4'
gem 'nokogiri', '>= 1.10.4'
gem 'sidekiq' # ,  '< 7'
group :development do
  gem 'annotate'
  gem 'pry-rails'
  gem 'railroady'
  gem 'rails-erd'
  # gem "better_errors"
  gem 'rails_db'
  # gem 'i18n-tasks', github: 'apaokin/i18n-tasks'
  gem 'letter_opener_web', '~> 2.0'
  gem 'minitest-reporters'
  gem 'rubocop'
  gem 'rubocop-rails'
  gem 'ruby-lsp-rspec', require: false
end

gem 'sinatra', '>= 1.3.0', require: nil

gem 'mina' # , github: "zhum/mina", require: false
# gem "mina-rbenv-addons", require: false
# gem "mina-foreman", github: "mina-deploy/mina-foreman"
# gem "mina-foreman", github: "asabourin/mina-foreman", require: false
# gem "mina-rails"
# gem "mina-git"

# should be loader earlier than engines
gem 'octoface', path: 'engines/octoface'
# other engines
gem 'announcements',  path: 'engines/announcements'
gem 'api',            path: 'engines/api'
gem 'authentication', path: 'engines/authentication'
gem 'cloud_computing', path: 'engines/cloud_computing'
gem 'comments', path: 'engines/comments'
gem 'core', path: 'engines/core'
gem 'face', path: 'engines/face'
gem 'foreman'
gem 'hardware', path: 'engines/hardware'
gem 'jobstat', path: 'engines/jobstat'
gem 'pack', path: 'engines/pack'
gem 'perf', path: 'engines/perf'
gem 'puma'
gem 'reports', path: 'engines/reports'
gem 'sessions', path: 'engines/sessions'
gem 'statistics', path: 'engines/statistics'
gem 'support', path: 'engines/support'
gem 'wikiplus', path: 'engines/wikiplus'

gem 'jquery-rails'
gem 'jquery-tablesorter'
gem 'jquery-ui-rails'

gem 'active_record_union'
gem 'config', github: 'railsconfig/config'
gem 'decorators' # , '~> 2.0.3'
gem 'redis'
gem 'redis-mutex'
gem 'whenever'
group :test, :development do
  gem 'factory_bot_rails'
  gem 'letter_opener'
end

group :test do
  gem 'activerecord-import', '>= 0.2.0'
  gem 'rspec-its'
  gem 'rspec-rails'
  gem 'rspec-sidekiq'
  gem 'selenium-webdriver'
  gem 'shoulda-matchers' # , '~> 6.0'
  # gem 'shoulda-matchers', '~> 4.0'
  # gem "test_after_commit"
  gem 'capybara-select-2'
  gem 'database_cleaner'
  # gem "factory_bot_rails"
  gem 'capybara'
  gem 'codeclimate-test-reporter', require: false
  gem 'phantomjs', github: 'colszowka/phantomjs-gem'
end
# gem 'sprockets-rails', '2.3.3'
gem 'ffi' # , '1.16.3'
gem 'rails-i18n' # , '~> 7.0.0'
