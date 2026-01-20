#!/bin/sh
set -e
rm -f tmp/pids/server.pid
cp config/database.yml.example config/database.yml
bundle install
rails s -b 0.0.0.0
