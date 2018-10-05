require "mina/bundler"
require "mina/rbenv"
#require "mina/rbenv/addons"
#require "mina/foreman"
require "mina/rails"
require "mina/git"
#require "mina/systemd"

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
set :shared_dirs, %w(public/uploads log vendor/bundle)
set :shared_files, %w(config/puma.rb config/settings.yml config/database.yml)
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

desc "Deploys the current version to the server."
task :deploy => :environment do
  deploy do
    invoke :"git:clone"
    invoke :"deploy:link_shared_paths"
    #invoke :"bundle:install"
    command "rm -f Gemfile.lock"
    command "bundle install"
    invoke :"rails:db_migrate"
    #invoke :"rails:assets_precompile"
    command %{RAILS_ENV=production bundle exec rake assets:precompile EXECJS_RUNTIME='Node' JRUBY_OPTS="-J-d32 -X-C"}
    comment "Done precompile"
    invoke :"deploy:cleanup"
    comment "Done cleanup"
    invoke :"set_whenever"

    #on :launch do
    #  invoke :"export_foreman"
    #  #invoke :"foreman:export"
    #  invoke :"foreman:restart"
    #  invoke :'systemctl:restart', 'octoshell'
    #end
  end
end

task :set_whenever do
  comment "Update cron tasks"
  command "rbenv exec bundle exec whenever -w"
end

task :export_foreman do
  set :export_cmd, "rbenv exec bundle exec foreman export #{fetch(:foreman_format)} #{fetch(:deploy_to)}/tmp/foreman -a #{fetch(:foreman_app)} -u #{fetch(:foreman_user)} -d #{fetch(:current_path)} -l #{fetch(:foreman_log)}"
  set :copy_cmd, "sudo cp #{fetch(:deploy_to)}/tmp/foreman/* #{fetch(:foreman_location)}"
  comment "Exporting foreman procfile for #{fetch(:foreman_app)}"
  invoke :"rbenv:load"
  command %{
    #{echo_cmd %[(cd #{fetch(:current_path)} ; #{fetch(:export_cmd)} ; #{fetch(:copy_cmd)})]}
  }
end

