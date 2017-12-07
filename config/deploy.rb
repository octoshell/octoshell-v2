require "mina/bundler"
require "mina/rbenv"
#require "mina/rbenv/addons"
#require "mina/foreman"
require "mina/rails"
require "mina/git"
#require "mina/systemd"

domain=ENV['DEPLOY_DOMAIN'] || "ooctoshell-v2.parallel.ru"
user=ENV['DEPLOY_USER'] || 'admin'
ruby_ver=ENV['DEPLOY_RUBY'] || "jruby-9.1.10.0"
repo=ENV['DEPLOY_REPO'] || "https://github.com/octoshell/octoshell-v2.git"
branch=ENV['DEPLOY_BRANCH'] || "rails4_2_jruby_9000"
dbuser=ENV['DEPLOY_DBUSER'] || "octo"
dbpass=ENV['DEPLOY_DBPASS'] || "octopass"

set :domain, domain
set :forward_agent, true
set :application, "octoshell2"
set :user, user
set :dbuser, dbuser
set :dbpass, dbpass
set :rbenv_ruby_version, ruby_ver
set :deploy_to, "/var/www/#{fetch(:application)}"
#set :deploy_to, "/var/www/octoshell2"
set :repository, repo
set :branch, branch
set :keep_releases, 5
#set :foreman_app, 'octoshell3'
#old set :shared_paths, %w(public/uploads config/puma.rb config/settings.yml config/database.yml log vendor/bundle)
set :shared_dirs, %w(public/uploads log )
set :shared_files, %w(config/puma.rb config/settings.yml config/database.yml)
#set :shared_paths, %w(public/uploads config/puma.rb config/settings.yml config/database.yml log)
set :force_asset_precompile, true

task :environment do
  invoke :"rbenv:load"
end

task setup: :environment do
  command %[mkdir -p "#{fetch(:deploy_to)}/shared/log"]
  command %[chmod g+rx,u+rwx "#{fetch(:deploy_to)}/shared/log"]

  command %[mkdir -p "#{fetch(:deploy_to)}/shared/config"]
  command %[chmod g+rx,u+rwx "#{fetch(:deploy_to)}/shared/config"]

  command %[touch "#{fetch(:deploy_to)}/shared/config/database.yml"]
  comment %[Be sure to edit 'shared/config/database.yml'.]

end
#task setup: :environment do
#  queue! %[mkdir -p "#{deploy_to}/shared/log"]
#  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/log"]
#
#  queue! %[mkdir -p "#{deploy_to}/shared/config"]
#  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/config"]
#
#  queue! %[touch "#{deploy_to}/shared/config/database.yml"]
#  queue  %[echo "-----> Be sure to edit 'shared/config/database.yml'."]
#end

task :setup_database => :environment do
  database_yml = <<-DATABASE.dedent
development: &def
  adapter: postgresql
  encoding: unicode
  database: new_octoshell_development
  user: #{fetch(:dbuser)}
  password: "#{fetch(:octopass)}"

test:
  <<: *def
  database: new_octoshell_test

production:
  <<: *def
  database: new_octoshell_production
  pool: 10
  min_messages: warning
  DATABASE
  comment "-----> Populating database.yml"
  command %{
    echo "#{database_yml}" > #{fetch(:deploy_to)}/shared/config/database.yml
  }
  comment "-----> Done"
end

task :setup_runner => :environment do
  run_file = <<-RUN.dedent
  #!/bin/bash

  cd /var/www/octoshell2/current
  exec "\$@"
  RUN
  command %{
    echo "#{run_file}" > /var/www/octoshell2/run_current
    chmod a+x /var/www/octoshell2/run_current
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

#desc "Deploys the current version to the server."
#task :deploy => :environment do
#  deploy do
#    invoke :"git:clone"
#    invoke :"deploy:link_shared_paths"
#    invoke :"bundle:install"
#    invoke :"rails:db_migrate"
#    invoke :"rails:assets_precompile"
#    comment "Done precompile"
#    invoke :"deploy:cleanup"
#    comment "Done cleanup"
#    invoke :"set_whenever"
#
#    #on :launch do
#    #  invoke :"export_foreman"
#    #  #invoke :"foreman:export"
#    #  invoke :"foreman:restart"
#    #  invoke :'systemctl:restart', 'octoshell'
#    #end
#  end
#end
desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    invoke :"git:clone"
    invoke :"deploy:link_shared_paths"
    invoke :"bundle:install"
    invoke :"rails:assets_precompile"
    invoke :"rails:db_migrate"
    invoke :"deploy:cleanup"
    invoke :"set_whenever"
    invoke :"check_secrets"

    on :launch do
#      invoke :restart_service
    end
  end
end

task :check_secrets do
  comment "Create secrets if needed"
  command "test -f /var/www/octoshell2/shared/config/settings.yml || (echo \"cookie_token: $(rbenv exec bundle exec rake secret)\" > /var/www/octoshell2/shared/config/settings.yml)"
end

task :set_whenever do
  comment "Update cron tasks"
  command "rbenv exec bundle exec whenever -w"
end

task :restart_service do
  comment "Restarting service!"
  command "sudo systemctl restart octoshell"
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

