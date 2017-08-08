
set :path, "/home/andrey/octoshell/"
set :output, "/home/andrey/octoshell/log/cron.log"
set :environment, :development
ruby_path = "/home/andrey/.rbenv/bin/rbenv exec"
job_type :rake, "cd :path && RAILS_ENV=:environment #{ruby_path} bundle exec rake :task :output"

every 2.hours do
  rake "db:backup"
end
every 1.day do
	rake "pack:expired"
   
end

