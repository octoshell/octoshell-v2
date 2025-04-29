FROM --platform=linux/amd64 ruby:2.7.6-slim
ENV BUNDLER_VERSION=2.1.4
RUN apt-get update -qq && apt-get install -y -qq nodejs libpq-dev\
  git curl wget build-essential libssl-dev libreadline-dev zlib1g-dev yarnpkg python2 python-is-python2
RUN gem install bundler -v 2.1.4
WORKDIR /app
COPY . .
RUN cp ./config/database.yml.example ./config/database.yml
RUN bundle config build.nokogiri --use-system-libraries
RUN gem install libv8 -v '3.16.14.19' --source 'https://rubygems.org/'
RUN bundle check || bundle install
#ENTRYPOINT ["./entrypoints/docker-entrypoint.sh"]
