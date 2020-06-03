FROM phusion/passenger-ruby26:1.0.9

ENV APP_HOME /opt/idb/
ENV BUNDLE_PATH /bundle
WORKDIR $APP_HOME

# enable nginx
RUN rm -f /etc/service/nginx/down

RUN bash -lc 'rvm install ruby-2.6.3'
RUN bash -lc 'rvm --default use ruby-2.6.3'
RUN gem update --system && gem install bundler

COPY --chown=app:app . .

RUN bundle install

ADD nginx.conf /etc/nginx/sites-enabled/default
EXPOSE 80
CMD ["/sbin/my_init"]
