web: rbenv exec bundle exec puma -p $PORT --config config/puma.rb

sq-auth-mailer: rbenv exec bundle exec sidekiq -q auth_mailer
sq-core-mailer: rbenv exec bundle exec sidekiq -q core_mailer
sq-support-mailer: rbenv exec bundle exec sidekiq -q support_mailer
sq-sessions-mailer: rbenv exec bundle exec sidekiq -q sessions_mailer
sq-announcements-mailer: rbenv exec bundle exec sidekiq -q announcements_mailer

sq-synchronizer: rbenv exec bundle exec sidekiq -q synchronizer
sq-sessions-starter: rbenv exec bundle exec sidekiq -q sessions_starter
sq-sessions-validator: rbenv exec bundle exec sidekiq -q sessions_validator
sq-statistics-collector: rbenv exec bundle exec sidekiq -q stats_collector
