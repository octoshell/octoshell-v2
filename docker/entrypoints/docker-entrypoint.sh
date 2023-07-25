#!/bin/sh
set -e
rm -f tmp/pids/server.pid
cp config/database.yml.example config/database.yml
rails s -b 0.0.0.0
# bundle install
