require "mina/bundler"
require "mina/rbenv"
require "mina/rbenv/addons"
require "mina/foreman"
require "mina/rails"
require "mina/git"

set :domain, "users.parallel.ru"
set :forward_agent, true
set :application, "octoshell2"
set :user, "admin"
set :rbenv_ruby_version, "jruby-1.7.16.1"
set :deploy_to, "/var/www/#{application}"
set :repository, "git@github.com:octoshell/octoshell-v2.git"
set :branch, "master"
set :keep_releases, 3
set :shared_paths, %w(public/uploads config/puma.rb config/settings.yml config/database.yml log)

task :environment do
  invoke :"rbenv:load"
end

task setup: :environment do
  queue! %[mkdir -p "#{deploy_to}/shared/log"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/log"]

  queue! %[mkdir -p "#{deploy_to}/shared/config"]
  queue! %[chmod g+rx,u+rwx "#{deploy_to}/shared/config"]

  queue! %[touch "#{deploy_to}/shared/config/database.yml"]
  queue  %[echo "-----> Be sure to edit 'shared/config/database.yml'."]
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

    to :launch do
      invoke :"export_foreman"
      invoke "foreman:restart"
    end
  end
end

task :set_whenever do
  queue "echo '-----> Update cron tasks'"
  queue "rbenv exec bundle exec whenever -w"
end

task :export_foreman do
  export_cmd = "rbenv exec bundle exec foreman export #{foreman_format} #{deploy_to!}/tmp/foreman -a #{foreman_app} -u #{foreman_user} -d #{deploy_to!}/#{current_path!} -l #{foreman_log}"
  copy_cmd = "sudo /usr/bin/for_cp #{deploy_to!}/tmp/foreman/* #{foreman_location}"
  queue %{
    echo "-----> Exporting foreman procfile for #{foreman_app}"
    #{echo_cmd %[cd #{deploy_to!}/#{current_path!} ; #{export_cmd} ; #{copy_cmd}]}
  }
end
