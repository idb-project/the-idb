#!/bin/sh

set -x

# try to load the schema
bundle exec rake db:schema:load >/dev/null 2>&1 || true

apachectl -D FOREGROUND &

tail -q -f /var/log/apache2/*.log

