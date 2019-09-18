require "mina/bundler"
require "mina/rbenv"
#require "mina/rbenv/addons"
#require "mina/foreman"
require "mina/rails"
require "mina/git"
#require "mina/systemd"

#set :execution_mode, :printer

domain=ENV['DEPLOY_DOMAIN'] || "ooctoshell-v2.parallel.ru"
user=ENV['DEPLOY_USER'] || 'admin'
port=ENV['DEPLOY_PORT'] || 22
ruby_ver=ENV['DEPLOY_RUBY'] || "jruby-9.1.10.0"
repo=ENV['DEPLOY_REPO'] || "https://github.com/octoshell/octoshell-v2.git"
branch=ENV['DEPLOY_BRANCH'] || "rails4_2_jruby_9000"
dbuser=ENV['DEPLOY_DBUSER'] || "octo"
dbpass=ENV['DEPLOY_DBPASS'] || "octopass"

set :domain, domain
set :forward_agent, true
set :application, "octoshell2"
set :user, user
set :port, port
set :dbuser, dbuser
set :dbpass, dbpass
set :rbenv_ruby_version, ruby_ver
set :deploy_to, "/var/www/#{fetch(:application)}"
#set :deploy_to, "/var/www/octoshell2"
set :repository, repo
set :branch, branch
set :keep_releases, 5
#set :foreman_app, 'octoshell3'
#old set :shared_paths, %w(public/fonts public/uploads config/puma.rb config/settings.yml config/database.yml log vendor/bundle)
set :shared_dirs, %w(public/uploads log public/fonts public/assets)
set :shared_files, %w(config/puma.rb config/settings.yml config/database.yml config/secrets.yml)
set :rails_env, 'production'
set :force_asset_precompile, true

task :remote_environment do
  invoke :"rbenv:load"
end

task setup: :remote_environment do
  command %[mkdir -p "#{fetch(:deploy_to)}/shared/log"]
  command %[chmod g+rx,u+rwx "#{fetch(:deploy_to)}/shared/log"]

  command %[mkdir -p "#{fetch(:deploy_to)}/shared/config"]
  command %[chmod g+rx,u+rwx "#{fetch(:deploy_to)}/shared/config"]

  command %[touch "#{fetch(:deploy_to)}/shared/config/database.yml"]
  comment %[Be sure to edit 'shared/config/database.yml'.]

end

task :setup_database => :remote_environment do
  database_yml = <<-DATABASE.dedent
development: &def
  adapter: postgresql
  encoding: unicode
  database: new_octoshell_development
  user: #{fetch(:dbuser)}
  password: "#{fetch(:dbpass)}"

test:
  <<: *def
  database: new_octoshell_test

production:
  <<: *def
  database: new_octoshell
  pool: 10
  min_messages: warning
  DATABASE
  comment "-----> Populating database.yml"
  command %{
    echo "#{database_yml}" > #{fetch(:deploy_to)}/shared/config/database.yml
  }
  comment "-----> Database configured."
end

task :setup_runner => :remote_environment do
  run_file = <<-RUN.dedent
  #!/bin/bash

  cd #{fetch(:deploy_to)}/current
  exec "\$@"
  RUN
  command %{
    echo "#{run_file}" > #{fetch(:deploy_to)}/run_current
    chmod a+x #{fetch(:deploy_to)}/run_current
  }
end

#
## See https://github.com/cespare/ruby-dedent/blob/master/lib/dedent.rb
##
class String
  def dedent
   lines = split "\n"
   return self if lines.empty?
   indents = lines.map do |line|
     line =~ /\S/ ? (line.start_with?(" ") ? line.match(/^ +/).offset(0)[1] : 0) : nil
   end
   min_indent = indents.compact.min
   return self if min_indent.zero?
   lines.map { |line| line =~ /\S/ ? line.gsub(/^ {#{min_indent}}/, "") : line  }.join "\n"
  end
end

desc "Deploys the current version to the server."
task :deploy => :remote_environment do
  deploy do
    comment "Start deploy..."
    command "hostname"
    command "pwd"
    invoke :"git:clone"
    invoke :"deploy:link_shared_paths"
    invoke :"bundle:install"
    invoke :"rails:assets_precompile"
    invoke :"copy_migrations"
    invoke :"rails:db_migrate"
    invoke :"deploy:cleanup"
  end
end

desc "Seed if needed"
task :"seed_if_needed" do
  command "test #{fetch(:deploy_to)}/seed_done.txt || RACK_ENV=production rbenv exec bundle exec rake db:seed && touch #{fetch(:deploy_to)}/seed_done.txt"
end

desc "Copy migrations from engines"
task :"copy_migrations" do
  comment "Copying migrations from railties."
  command "RACK_ENV=production rbenv exec bundle exec rake railties:install:migrations"
end

desc "Prepare for first deploy"
task :deploy_1 do
  run(:local) do
    command "hostname"
    command "pwd"
    comment "Copying puma.rb"
    command "scp config/puma.rb #{fetch(:user)}@#{fetch(:domain)}:#{fetch(:shared_path)}/config/puma.rb"
    comment "Copying settings.yml"
    command "scp config/settings.yml #{fetch(:user)}@#{fetch(:domain)}:#{fetch(:shared_path)}/config/settings.yml"
    command "scp public/fonts/* #{fetch(:user)}@#{fetch(:domain)}:#{fetch(:shared_path)}/fonts/"
    invoke :"git:clone"
    invoke :"deploy:link_shared_paths"
    #invoke :"bundle:install"
    command "rm -f Gemfile.lock"
    command "bundle install"
    invoke :"rails:db_migrate"
    #invoke :"rails:assets_precompile"
    #command %{RAILS_ENV=production bundle exec rake assets:precompile EXECJS_RUNTIME='Node' JRUBY_OPTS="-J-d32 -X-C"}
    command %{RAILS_ENV=production bundle exec rake assets:precompile"}
    comment "Done precompile"
    invoke :"deploy:cleanup"
    comment "Done cleanup"
    invoke :"set_whenever"

  end
end

task :make_seed => :remote_environment do
  in_path(fetch(:current_path)) do
    command "RACK_ENV=production rbenv exec bundle exec rake db:seed"
  end
end

task :make_seed => :remote_environment do
  in_path(fetch(:current_path)) do
    comment "Seed database..."
    command %{pwd; RACK_ENV=production rbenv exec bundle exec rake db:migrate}
    comment "Migrated..."
    command %{RACK_ENV=production rbenv exec bundle exec rake db:seed}
    comment "Seeded..."
  end
end

desc "Update bundles"
task :update_bundles => :remote_environment do
  in_path(fetch(:current_path)) do
    comment "Rebuild bundles..."
    command %{for i in engines/*; do (cd $i; rm Gemfile.lock; RACK_ENV=production rbenv exec bundle install); done}
  end
end

task :check_secrets do
  #comment "Create secrets if needed"
  #command "test -f /var/www/octoshell2/shared/config/settings.yml && (sed -i 's/development:/production:/' /var/www/octoshell2/shared/config/settings.yml)"
  #command "test -f /var/www/octoshell2/shared/config/settings.yml || (echo \"cookie_token: $(rbenv exec bundle exec rake secret)\" > /var/www/octoshell2/shared/config/settings.yml)"
end

task :set_whenever do
  comment "Update cron tasks"
  command "rbenv exec bundle exec whenever -w"
end

task :restart_service do
  comment "Restarting service!"
  #command "sudo systemctl restart octoshell"
  command "touch /var/www/octoshell2/restart.txt"
end

#task :export_foreman do
#  set :export_cmd, "rbenv exec bundle exec foreman export #{fetch(:foreman_format)} #{fetch(:deploy_to)}/tmp/foreman -a #{fetch(:foreman_app)} -u #{fetch(:foreman_user)} -d #{fetch(:current_path)} -l #{fetch(:foreman_log)}"
#  set :copy_cmd, "sudo cp #{fetch(:deploy_to)}/tmp/foreman/* #{fetch(:foreman_location)}"#
  comment "Exporting foreman procfile for #{fetch(:foreman_app)}"
#  invoke :"rbenv:load"
#  command %{
#    #{echo_cmd %[(cd #{fetch(:current_path)} ; #{fetch(:export_cmd)} ; #{fetch(:copy_cmd)})]}
#  }
#end
task :export_foreman do
  export_cmd = "rbenv exec bundle exec foreman export #{foreman_format} #{deploy_to!}/tmp/foreman -a #{foreman_app} -u #{foreman_user} -d #{deploy_to!}/#{current_path!} -l #{foreman_log}"
  copy_cmd = "sudo /usr/bin/for_cp #{deploy_to!}/tmp/foreman/* #{foreman_location}"
  queue %{
    echo "-----> Exporting foreman procfile for #{foreman_app}"
      #{echo_cmd %[cd #{deploy_to!}/#{current_path!} ; #{export_cmd} ; #{copy_cmd}]}
 
  }
end

