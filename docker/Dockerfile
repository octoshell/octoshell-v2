FROM ruby:2.7.6-slim
ENV BUNDLER_VERSION=2.1.4
RUN apt-get update -qq && apt-get install -y -qq nodejs libpq-dev\
  git curl wget build-essential libssl-dev libreadline-dev zlib1g-dev yarnpkg
RUN gem install bundler -v 2.1.4
WORKDIR /app
COPY . ./
RUN cp config/database.yml.example config/database.yml
RUN bundle config build.nokogiri --use-system-libraries
RUN bundle check || bundle install
#ENTRYPOINT ["./entrypoints/docker-entrypoint.sh"]
