set :path, "/var/www/octoshell2/current/"
set :output, "/var/www/octoshell2/shared/log/cron.log"

ruby_path = "rbenv exec"
job_type :rake, "cd :path && RAILS_ENV=:environment #{ruby_path} bundle exec rake :task :output"

every 2.hours do
  rake "db:backup"
end

