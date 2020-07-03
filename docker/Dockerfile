FROM debian:buster-slim

ARG ruby_version=2.6.3
ARG ruby_build_version=20200520
ARG bundler_version=2.0.2

# just use a login shell.
SHELL [ "/bin/bash", "-l", "-c" ]

# install ruby-build
RUN apt-get update && apt-get install -y curl gnupg
RUN curl https://codeload.github.com/rbenv/ruby-build/tar.gz/v${ruby_build_version} -O
RUN tar xf v${ruby_build_version}
RUN ruby-build-${ruby_build_version}/install.sh

# install ruby dependencies
RUN apt-get install -y autoconf bison build-essential libssl-dev libyaml-dev libreadline6-dev zlib1g-dev libncurses5-dev libffi-dev libgdbm6 libgdbm-dev libdb-dev bzip2

# install ruby, skipping docs
RUN env RUBY_CONFIGURE_OPTS=--disable-install-doc ruby-build ${ruby_version} /usr/local
RUN gem install bundler -v ${bundler_version}

# install apache2 and passenger
RUN apt-get update && apt-get install -y apache2 apt-transport-https ca-certificates
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
RUN echo deb https://oss-binaries.phusionpassenger.com/apt/passenger buster main > /etc/apt/sources.list.d/passenger.list
RUN apt-get update && apt-get install -y libapache2-mod-passenger
RUN a2enmod passenger
RUN /usr/bin/passenger-config validate-install

# install idb
RUN apt-get update && apt-get install -y git libmariadb-dev
RUN useradd -d /opt/idb -M -r idb && usermod -g idb idb

RUN mkdir /opt/idb && chown idb:idb /opt/idb
WORKDIR /opt/idb

USER idb
COPY --chown=idb:idb Gemfile Gemfile.lock /opt/idb/
RUN env RAILS_ENV=production bundle install --path=vendor/bundle
COPY --chown=idb:idb . /opt/idb
RUN mv docker/config config

USER root
ADD docker/apache.conf /etc/apache2/sites-available/idb.conf
RUN a2dissite 000-default && a2ensite idb
EXPOSE 80


