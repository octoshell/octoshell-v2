FROM debian:buster-slim
MAINTAINER srcc

# update and install dependencies
# ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get install -y --no-install-recommends \
        ca-certificates \
        netbase \
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
        libsqlite3-dev nodejs npm \
  && rm -rf /var/lib/apt/lists/*

RUN curl https://raw.githubusercontent.com/rbenv/rbenv-installer/master/bin/rbenv-installer | bash || echo "done, error code is fine"
RUN echo "export PATH=~/.rbenv/bin:\$PATH" >> ~/.bashrc && \
    echo "eval \"\$(rbenv init -)\"" >> ~/.bashrc && \
    bash -c "source ~/.bashrc ; rbenv install 2.5.1 ; rbenv global 2.5.1" && \
    bash -c "source ~/.bashrc ; gem install bundler --version '< 2.0' ; bundle config --global --jobs 8" && \
    npm install -g yarn && \
    mkdir /octoshell-v2-build


WORKDIR /octoshell-v2-build

COPY ./Gemfile ./
RUN cat Gemfile | grep -E -v "path.*engines" > Gemfile.global && \
    bash -c "source ~/.bashrc ; bundle install --gemfile=Gemfile.global"

COPY ./ /octoshell-v2-build

RUN rm -f Gemfile.lock && bash -c "source ~/.bashrc ; bundle install" && cp config/database.yml.example config/database.yml

COPY docker/docker_init.sh  /octoshell-v2-build

ENTRYPOINT ["/bin/bash", "-c"]

# it is made so to allow overriding CMD with an arbitrary command
CMD ["bash /octoshell-v2-build/docker_init.sh"]

