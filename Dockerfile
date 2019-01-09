FROM ubuntu:13.10

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update

# Locales

RUN locale-gen en_US.UTF-8
RUN dpkg-reconfigure -fnoninteractive locales
RUN update-locale LC_ALL="en_US.UTF-8" LANG="en_US.UTF-8" LANGUAGE="en_US"

# Redis

RUN apt-get -y install redis-server

# NodeJS

RUN apt-get -y install nodejs

# git

RUN apt-get -y install git-core

# Ruby

RUN apt-get -y install build-essential zlib1g-dev libreadline-dev libssl-dev libcurl4-openssl-dev wget libpq-dev libxml2 libxslt-dev libxml2-dev libmagickwand-dev

# Java 7 (openjdk)
RUN apt-get install -y openjdk-7-jdk

# set a bunch of environment variables
ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64/
ENV PATH $JAVA_HOME/bin:$PATH

RUN git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
RUN git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build
RUN echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.profile
RUN echo 'eval "$(rbenv init -)"' >> ~/.profile
ENV PATH /.rbenv/bin:/.rbenv/shims:$PATH
RUN rbenv init -

RUN echo "gem: --no-rdoc --no-ri" >> ~/.gemrc

RUN rbenv install jruby-1.7.13 && rbenv global jruby-1.7.13
RUN gem install bundler
RUN gem install foreman
RUN rbenv rehash

# PostgreSQL

RUN apt-key adv --keyserver keyserver.ubuntu.com --recv-keys B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8
RUN echo "deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main" > /etc/apt/sources.list.d/pgdg.list
RUN apt-get update

RUN apt-get -y -q install python-software-properties software-properties-common
RUN apt-get -y -q install postgresql-9.3 postgresql-client-9.3 postgresql-contrib-9.3

USER postgres

RUN /etc/init.d/postgresql start &&\
    psql --command "CREATE USER octo WITH SUPERUSER PASSWORD 'octo';"
USER root

ADD config/docker/pg_hba.conf /etc/postgresql/9.3/main/pg_hba.conf

# SSH settings

RUN mkdir -p /root/.ssh
RUN chmod 0700 /root/.ssh
ADD config/docker/ssh_config /root/.ssh/config
RUN chown -R root:root /root/.ssh

# nginx

RUN apt-get -y install nginx
RUN rm /etc/nginx/sites-available/default
ADD config/docker/nginx_config /etc/nginx/conf.d/octoshell-basic.conf

# Gitlub dependencies
# TODO: move on top
RUN apt-get -y install libyaml-dev libgdbm-dev libncurses5-dev libffi-dev curl openssh-server checkinstall libicu-dev logrotate

# Rails

ENV RAILS_ENV production
ENV RACK_ENV production
ENV PORT 3000
ENV RAILS_GROUPS assets

ADD ./ /var/www/octoshell-basic
ADD config/docker/puma.rb /root/puma.rb

ADD bin/docker_run /root/docker_run
RUN chmod 0700 /root/docker_run

EXPOSE 80

WORKDIR /var/www/octoshell-basic

CMD /root/docker_run
