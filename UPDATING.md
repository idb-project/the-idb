## Updating idb

### General Steps

$ sudo dpkg -i idb.deb
$ export PATH=/opt/idb/vendor/ruby/bin/:$PATH
$ cd /opt/idb && RAILS_ENV=production bundle exec rake db:migrate
$ cd /opt/idb && RAILS_ENV=production bundle exec rake assets:precompile
$ cp config.sample/initializers/version.rb config/initializers/

Always:

* restart webserver / application server
* restart sidekiq

### Update Config File

* If present one can remove the puppetDB options "apt_distributions" and "yum_distributions" from application.yml, they are obsolete.
