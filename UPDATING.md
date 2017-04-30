## Updating idb

### General Steps

$ sudo dpkg -i idb-$(VERSION).deb

* make sure, that /opt/idb/config is still a symlink to the configuration in /etc/idb/,
and not to the config-example directory

$ export PATH=/opt/idb/vendor/ruby/bin/:$PATH
$ cd /opt/idb && RAILS_ENV=production bundle exec rake db:migrate
$ cd /opt/idb && RAILS_ENV=production bundle exec rake assets:precompile
$ cp config.sample/initializers/version.rb config/initializers/

Always:

* restart webserver / application server
* restart sidekiq

### Update Config File

* If present one can remove the puppetDB options "apt_distributions" and "yum_distributions" from application.yml, they are obsolete.
