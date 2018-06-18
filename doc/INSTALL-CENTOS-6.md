# Install instructions for The IDB on CentOS 6

* clone the repo into /opt/the-idb

## create the config directory

* copy config-example/ to somewhere else and symlink it to config/
```
$ cd /opt/the-idb/
$ sudo cp -r config-example /etc/the-idb
$ ln -s /etc/the-idb config
```

## package / repo prerequisites

* install epel-release and enable the epel repo
 
* install the mysql 5.7 repo 
```
yum localinstall -y https://dev.mysql.com/get/mysql57-community-release-el6-11.noarch.rpm
```
* and the following packages from there
	* mysql-community-server
  	* mysql-community-devel
* enable and start the mysql-server `chkconfig --add mysqld && service mysqld start`
* set a new mysql root password, you can find the temporary one in /var/log/mysqld.log
```
service mysqld start
grep password /var/log/mysqld.log 
mysql -u root -p
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('securepass');
```
* install the atomic repo for redis and install redis
```
yum localinstall -y https://www6.atomicorp.com/channels/atomic/centos/6/x86_64/RPMS/atomic-release-1.0-21.el6.art.noarch.rpm
yum install -y redis
```
* enable and start redis: `chkconfig --add redis && service redis start`

* install [Phusion Passenger](https://www.phusionpassenger.com/library/install/apache/install/oss/el6/) from the official repo


## create a database and a user
* run `service mysqld start`if mysqld is not running yet
```
mysql -u root -p
CREATE DATABASE idb;
GRANT ALL ON idb.* TO 'idb'@'localhost' IDENTIFIED BY '<somepassword>';
FLUSH PRIVILEGES;
```

* set the database configuration in /opt/the-idb/config/database.yml
* _Caution:_ adjust the socket to /var/lib/mysql/mysql.sock

## Install a LDAP server

* if you are not using an foreign LDAP server, you have to install one: `yum install 389-ds-base 389-admin`
* run `setup-ds-admin.pl`to set it up
* configure the LDAP access in /opt/the-idb/config/application.yml
* for further infos on the user handling see ldap-and-usermanagement.md

## create an user and group

`useradd --user-group idb --home /opt/the-idb --no-create-home`

## change owner and group

`chown -R idb.idb /opt/the-idb`

## install  RVM

* go to the [RVM](https://rvm.io/) website and install RVM
* run the following commands for installing ruby 2.2.4:
```
source /etc/profile.d/rvm.sh
rvm install ruby-2.2.4
rvm use --default ruby-2.2.4
rvm wrapper current bootup sidekiq
```

## install bundler and gems

```
cd /opt/the-idb 
gem install bundler
RAILS_ENV=production bundle install
```

## fill the database and precompile the assets
```
export RAILS_ENV=production
bundle exec rake db:migrate
bundle exec rake assets:precompile
```

## config files for apache and sidekiq

### /etc/httpd/conf.d/idb.conf

```
<VirtualHost *:80>
    ServerName idb.example.com
        DocumentRoot /opt/the-idb/public
        <Directory /opt/the-idb/public>
          # Relax Apache security settings
          Options FollowSymLinks
          AllowOverride all
          Require all granted
          # MultiViews must be turned off
          Options -MultiViews
        </Directory>
        PassengerUser idb 
        PassengerGroup idb
</VirtualHost>

<VirtualHost *:443>
        ServerName idb.example.com⁠⁠
        DocumentRoot /opt/the-idb/public

        <Directory /opt/the-idb/public>
            Options FollowSymLinks
        AllowOverride All
            Require all granted
    </Directory>

        SSLEngine on
        #SSLProtocol all -SSLv2 -SSLv3 
   SSLProtocol           all -SSLv3 -TLSv1.1
   SSLHonorCipherOrder   On
   SSLCipherSuite        DHE-RSA-AES256-GCM-SHA384:DHE-RSA-AES256-SHA:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-SHA
   SSLCertificateFile      /etc/ssl/certs/ssl-cert-snakeoil.pem
   SSLCertificateKeyFile /etc/ssl/private/ssl-cert-snakeoil.key
   PassengerUser idb 
   PassengerGroup idb
# and all the other regular ssl options like certificate etc. pp.
</VirtualHost>
```
restart apache `service apache2 restart` 

### /etc/init.d/sidekiq

```
#!/bin/bash

# chkconfig: 2345 82 55
# processname: sidekiq
# description: Runs sidekiq for the IDB.


# Include RedHat function library
. /etc/rc.d/init.d/functions

# The name of the service
NAME=sidekiq

### Environment variables
RAILS_ENV="production"

USER=idb
GROUP=idb
APP_PATH=/opt/the-idb

SPID=/var/run/sidekiq.pid
SLOCK=/var/lock/sidekiq

start() {
  cd $APP_PATH

  # Start sidekiq
  echo -n $"Starting sidekiq: "
  daemon --pidfile=$SPID --user=$USER  "/usr/local/rvm/bin/bootup_sidekiq -d -e $RAILS_ENV -L $APP_PATH/log/sidekiq.log"
  sidekiq=$?
  [ $sidekiq -eq 0 ] && touch $SLOCK
  echo

  retval=$sidekiq
  return $retval
}

stop() {
  cd $APP_PATH

  # Stop sidekiq
  echo -n $"Stopping sidekiq: "
  killproc -p $SPID
  sidekiq=$?
  [ $sidekiq -eq 0 ] && rm -f $SLOCK
  echo

  retval=$sidekiq
  return $retval
}

restart() {
  stop
  start
}

get_status() {
  status -p $SPID sidekiq
  sidekiq=$?

  retval=$sidekiq
  return $retval
}

query_status() {
  get_status >/dev/null 2>&1
  return $?
}

case "$1" in
  start)
    query_status && exit 0
    start
    ;;
  stop)
    query_status || exit 0
    stop
    ;;
  restart)
    restart
    ;;
  status)
    get_status
	exit $?
    ;;
  *)
    N=/etc/init.d/$NAME
    echo "Usage: $NAME {start|stop|restart|status}" >&2
    exit 1
    ;;
esac

exit 0

```
* enable sidekiq: `chkconfig --add sidekiq`
* start sidekiq: `service sidekiq start`

## configure config/secrets.yml

You need to configure the secretes file. Open `config/secrets.yml` in your editor and
put the following (with a unique secret) there:

```
production:
        secret_key_base: Piah8pohjiheegeu9Sha
```

