#require "mina/bundler"
require "mina/rbenv"
require "mina/rbenv/addons"
require "mina/foreman"
require "mina/rails"
require "mina/git"

set :domain, "octoshell-test.parallel.ru"
set :forward_agent, true
set :application, "octoshell2"
set :user, "admin"
set :rbenv_ruby_version, "jruby-9.1.5.0"
set :deploy_to, "/var/www/#{fetch(:application)}"
#set :deploy_to, "/var/www/octoshell2"
set :repository, "git@github.com:octoshell/octoshell-v2.git"
set :branch, "rails4_2_jruby_9000"
set :keep_releases, 3
set :shared_paths, %w(public/uploads config/puma.rb config/settings.yml config/database.yml log)

task :environment do
  invoke :"rbenv:load"
end

task setup: :environment do
  command %[mkdir -p "#{fetch(:deploy_to)}/shared/log"]
  command %[chmod g+rx,u+rwx "#{fetch(:deploy_to)}/shared/log"]

  command %[mkdir -p "#{fetch(:deploy_to)}/shared/config"]
  command %[chmod g+rx,u+rwx "#{fetch(:deploy_to)}/shared/config"]

  command %[touch "#{fetch(:deploy_to)}/shared/config/database.yml"]
  command  %[echo "-----> Be sure to edit 'shared/config/database.yml'."]
end

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

    on :launch do
      invoke :"export_foreman"
      invoke "foreman:restart"
    end
  end
end

task :set_whenever do
  command "echo '-----> Update cron tasks'"
  command "rbenv exec bundle exec whenever -w"
end

task :export_foreman do
  export_cmd = "rbenv exec bundle exec foreman export #{fetch(:foreman_format)} #{fetch(:deploy_to)}/tmp/foreman -a #{fetch(:foreman_app)} -u #{fetch(:foreman_user)} -d #{fetch(:deploy_to)}/#{fetch(:current_path)} -l #{fetch(:foreman_log)}"
  copy_cmd = "sudo /usr/bin/for_cp #{fetch(:deploy_to)}/tmp/foreman/* #{fetch(:foreman_location)}"
  command %{
    echo "-----> Exporting foreman procfile for #{fetch(:foreman_app)}"
    #{echo_cmd %[cd #{fetch(:deploy_to)}/#{fetch(:current_path)} ; #{fetch(:export_cmd)} ; #{fetch(:copy_cmd)}]}
  }
end

