nohup ./redis-server &

#service postgresql start

#sudo -u postgres psql -c "CREATE USER octo WITH PASSWORD 'octopass';"
#sudo -u postgres psql -c "ALTER USER octo CREATEDB;"

cd /octoshell-v2-build

source ~/.bashrc

#bundle exec rake db:create
bundle exec rake db:migrate
#bundle exec rake db:seed
bundle exec rake assets:precompile

bash ./dev

