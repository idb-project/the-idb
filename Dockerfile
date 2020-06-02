# ./Dockerfile
FROM phusion/passenger-ruby26
# set the app directory var
ENV APP_HOME /opt/idb
ENV BUNDLE_PATH /bundle
WORKDIR $APP_HOME
RUN apt-get update -qq
RUN apt-get install -y --no-install-recommends \
  build-essential \
  curl libssl-dev \
  git \
  unzip \
  zlib1g-dev \
  libxslt-dev \
  mysql-client
ADD . .
EXPOSE 3000
CMD ["/sbin/my_init"]
