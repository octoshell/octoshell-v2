FROM debian:buster
MAINTAINER srcc

# update and install dependencies
# ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y \
        build-essential sudo \
        wget curl \
        gcc g++ scons \
        make cmake \
        git \
        bash \
        vim \
        htop tcpdump \
        python3 python3-dev python3-venv \
        postgresql postgresql-server-dev-all \
        libssl-dev libreadline-dev zlib1g-dev \
        redis-server redis-tools \
        libsqlite3-dev nodejs npm

RUN npm install -g yarn

RUN curl https://raw.githubusercontent.com/rbenv/rbenv-installer/master/bin/rbenv-installer | bash || echo "done, error code is fine"
RUN echo "export PATH=~/.rbenv/bin:\$PATH" >> ~/.bashrc
RUN echo "eval \"\$(rbenv init -)\"" >> ~/.bashrc

RUN bash -c "source ~/.bashrc ; rbenv install 2.5.1 ; rbenv global 2.5.1"
RUN bash -c "source ~/.bashrc ; gem install bundler --version '< 2.0' ; bundle config --global --jobs 8"

RUN mkdir /root/octoshell-v2-build
WORKDIR /root/octoshell-v2-build

COPY ./Gemfile ./
RUN cat Gemfile | grep -E -v "path.*engines" > Gemfile.global

RUN bash -c "source ~/.bashrc ; bundle install --gemfile=Gemfile.global"

COPY ./ /root/octoshell-v2
WORKDIR /root/octoshell-v2

RUN rm -f Gemfile.lock
RUN bash -c "source ~/.bashrc ; bundle install"

RUN cp config/database.yml.example config/database.yml

COPY docker/docker_init.sh  /root/

ENTRYPOINT ["/bin/bash", "-c"]

# it is made so to allow overriding CMD with an arbitrary command
CMD ["bash /root/docker_init.sh"]

