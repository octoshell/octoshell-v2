web: rbenv exec bundle exec puma -e production --config config/puma.rb

sq-auth-mailer: RACK_ENV=production rbenv exec bundle exec sidekiq -q auth_mailer
sq-core-mailer: RACK_ENV=production rbenv exec bundle exec sidekiq -q core_mailer
sq-support-mailer: RACK_ENV=production rbenv exec bundle exec sidekiq -q support_mailer
sq-sessions-mailer: RACK_ENV=production rbenv exec bundle exec sidekiq -q sessions_mailer
sq-announcements-mailer: RACK_ENV=production rbenv exec bundle exec sidekiq -q announcements_mailer

sq-synchronizer: RACK_ENV=production rbenv exec bundle exec sidekiq -q synchronizer
sq-sessions-starter: RACK_ENV=production rbenv exec bundle exec sidekiq -q sessions_starter
sq-sessions-validator: RACK_ENV=production rbenv exec bundle exec sidekiq -q sessions_validator
sq-statistics-collector: RACK_ENV=production rbenv exec bundle exec sidekiq -q stats_collector
