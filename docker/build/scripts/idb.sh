#!/bin/sh

set -x

export HOME=/opt/idb
su -p idb -c 'bundle exec rake db:migrate --trace' || true
su -p idb -c 'bundle exec rake assets:precompile --trace' || true

apachectl -D FOREGROUND &

tail -q -f /var/log/apache2/*.log

