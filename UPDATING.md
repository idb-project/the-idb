# Updating IDB

## General Steps

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


## Update Config File

### 1.6.3

The following settings have been added to configure admin users.

```
admin_group: 'admins,dc=fra,dc=bytemine,dc=net'
group_membership_attribute: 'uniqueMember'
```

Add this to the ldap-setting for the used environment.


### 1.6.2

* If present one can remove the puppetDB options "apt_distributions" and "yum_distributions" from application.yml, they are obsolete.
