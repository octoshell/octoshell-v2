#!/bin/sh
# bundle install
bundle exec sidekiq -C config/sidekiq.yml
