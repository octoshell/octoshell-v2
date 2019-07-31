#!/bin/sh

bundle exec rake railties:install:migrations
bundle exec rake db:migrate

