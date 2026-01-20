FROM ruby:3.2.10-slim
ENV BUNDLER_VERSION=4.0.3
RUN apt-get update -qq && apt-get install -y -qq nodejs libpq-dev\
  git curl wget build-essential libssl-dev libreadline-dev zlib1g-dev yarnpkg\
  libyaml-dev libffi-dev libgmp-dev rustc

RUN gem install bundler -v 4.0.3
WORKDIR /app
COPY . ./
RUN cp config/database.yml.example config/database.yml
#RUN bundle config build.nokogiri --use-system-libraries
RUN bundle install
#ENTRYPOINT ["./entrypoints/docker-entrypoint.sh"]
