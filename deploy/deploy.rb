require "mina/bundler"
require "mina/rbenv"
#require "mina/rbenv/addons"
#require "mina/foreman"
require "mina/rails"
require "mina/git"
# require "mina/scp"

#require "mina/systemd"

#set :execution_mode, :printer

domain=ENV['DEPLOY_DOMAIN'] || "ooctoshell-v2.parallel.ru"
user=ENV['DEPLOY_USER'] || 'admin'
ruby_ver=ENV['DEPLOY_RUBY'] || "jruby-9.1.10.0"
repo=ENV['DEPLOY_REPO'] || "https://github.com/octoshell/octoshell-v2.git"
branch=ENV['DEPLOY_BRANCH'] || "rails4_2_jruby_9000"
dbuser=ENV['DEPLOY_DBUSER'] || "octo"
dbpass=ENV['DEPLOY_DBPASS'] || "octopass"
sshport=ENV['DEPLOY_PORT'] || 22
identity=ENV['DEPLOY_IDENTITY']
deploy_to = ENV['DEPLOY_TO']

set :domain, domain
set :forward_agent, true
set :application, "octoshell2"
set :user, user
set :dbuser, dbuser
set :dbpass, dbpass
set :identity_file, identity
set :port, sshport
set :rbenv_ruby_version, ruby_ver
set :deploy_to, deploy_to
set :repository, repo
set :branch, branch
set :keep_releases, 1
#set :foreman_app, 'octoshell3'
#old set :shared_paths, %w(public/uploads config/puma.rb config/settings.yml config/database.yml log vendor/bundle)
set :shared_dirs, %w(public/uploads log secured_uploads public/images)
set :shared_files, %w(config/puma.rb config/secrets.yml config/settings.yml config/environments/production.rb
                      config/database.yml config/schedule.rb database.yml config/honeybadger.yml mail.sock)
#set :shared_paths, %w(public/uploads config/puma.rb config/settings.yml config/database.yml log)
set :force_asset_precompile, true
set :rails_env, 'production'
set :bundle_bin, 'bundle'
# set :bundle_path, nil
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
  host: /var/run/postgresql
  user: #{fetch(:dbuser)}
  password: "#{fetch(:dbpass)}"

test:
  <<: *def
  database: new_octoshell_test

production:
  <<: *def
  database: new_octoshell
  pool:  <%= ENV.fetch('RAILS_MAX_THREADS') { 20 } %>
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

task :copy_files do
  run(:local) do
      command "hostname"
      command "pwd"
      comment "Copying files"
      command "scp -i #{fetch(:identity_file)}  -P  #{fetch(:port)} merge_orgs.xlsx  #{fetch(:user)}@#{fetch(:domain)}:#{fetch(:shared_path)}/"
      command "scp -i #{fetch(:identity_file)}  -P  #{fetch(:port)} joining-orgs_2017_11-2.ods  #{fetch(:user)}@#{fetch(:domain)}:#{fetch(:shared_path)}/"
  end
end

desc "Deploys the current version to the server."
task :deploy => :remote_environment do
  deploy do
#    run(:remote) do
#    in_path(fetch(:current_path)) do
      comment "Start deploy..."
      command "hostname"
      command "pwd"
      invoke :"git:clone"
      invoke :"deploy:link_shared_paths"
      command "bundle install"
      command "rails assets:precompile"

      # command %{rm Gemfile.lock}
      # command %{rbenv local 2.5.1}
      # command %{gem install bundler -v "$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1)"}
      # invoke :'bundle:install'
      # command %{HONEYBADGER=1 bundle install}
      # invoke :"rails:db_migrate"
      # invoke :"rails:assets_precompile"
      # command %{RAILS_ENV=production bundle exec rails db:migrate}

      # command %{RAILS_ENV=production bundle exec rails support:required_fields}

      # command "sudo apt-get update"
      # command "sudo apt-get install -y nodejs"
      # comment "Copying files"
      # command %{RAILS_ENV=production bundle exec rake support:create_bot['strong_passworddwadwwad']}
      # command %{RAILS_ENV=production bundle exec rake core:remove_invalid_mergers}
      # command %{RAILS_ENV=production bundle exec rake reports:install}
      # command %{rails runner "Core::City.all.each { |c| c.checked = true; c.save } "}


      # command %{bundle exec rails runner -e production engines/core/scripts/ruby/support.rb}
      # command %{bundle exec whenever --update-crontab}


      invoke :"deploy:cleanup"
#      invoke :"set_whenever"
    on :launch do
#      invoke :restart_service
    end
  end
end




task generate_config: :remote_environment  do
  command "rails r deploy/deploy/copy_systemd_puma.rb #{fetch(:deploy_to)}"
end


desc "Seed if needed"
task :"seed_if_needed" do
  command "test #{fetch(:deploy_to)}/seed_done.txt || RACK_ENV=production rbenv exec bundle exec rake db:seed && touch #{fetch(:deploy_to)}/seed_done.txt"
end

desc "Prepare for first deploy"
task :deploy_1 do
  run(:local) do
      command "hostname"
      command "pwd"
      comment "Copying puma.rb"
      command "scp  -i #{fetch(:identity_file)} -P  #{fetch(:port)} config/puma.rb   #{fetch(:user)}@#{fetch(:domain)}:#{fetch(:shared_path)}/config/puma.rb"
      comment "Copying settings.yml"
      command "scp -i #{fetch(:identity_file)}   -P  #{fetch(:port)} config/settings.yml   #{fetch(:user)}@#{fetch(:domain)}:#{fetch(:shared_path)}/config/settings.yml"
      comment "Copying secrets.yml"
      command "scp -i #{fetch(:identity_file)}  -P  #{fetch(:port)} config/secrets.yml  #{fetch(:user)}@#{fetch(:domain)}:#{fetch(:shared_path)}/config/secrets.yml"
      comment "Copying honeybadger.yml"
      command "scp -i #{fetch(:identity_file)}  -P  #{fetch(:port)} config/honeybadger.yml  #{fetch(:user)}@#{fetch(:domain)}:#{fetch(:shared_path)}/config/honeybadger.yml"

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

task :set_whenever do
  comment "Update cron tasks"
  command "rbenv exec bundle exec whenever -w"
end

task :restart_service do
  comment "Restarting service!"
  command "sudo systemctl restart octoshell"
end

task :stop_test_server do
  invoke 'rbenv:load'
  in_path(fetch(:current_path)) do
    command "rbenv exec bundle exec pumactl stop"
  end
end

task :start_test_server do
  invoke 'rbenv:load'
  in_path(fetch(:current_path)) do
    command "export SERVER_PORT=8081"
    command "rbenv exec bundle exec pumactl start"
  end
end




#task :export_foreman do
#  set :export_cmd, "rbenv exec bundle exec foreman export #{fetch(:foreman_format)} #{fetch(:deploy_to)}/tmp/foreman -a #{fetch(:foreman_app)} -u #{fetch(:foreman_user)} -d #{fetch(:current_path)} -l #{fetch(:foreman_log)}"
#  set :copy_cmd, "sudo cp #{fetch(:deploy_to)}/tmp/foreman/* #{fetch(:foreman_location)}"
#  comment "Exporting foreman procfile for #{fetch(:foreman_app)}"
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

task :env do
   queue! %[HONEYBADGER="#{ENV['HONEYBADGER']}"]
end
