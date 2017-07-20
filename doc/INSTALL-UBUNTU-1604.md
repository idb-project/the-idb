# Install instructions for The IDB on Ubuntu 16.04

* clone the repo into /opt/the-idb

## create the config directory

* copy config-example/ to somewhere else and symlink it to config/
```
$ cd /opt/the-idb/
$ sudo cp config-example /etc/the-idb
$ ln -s /etc/the-idb config
```


* install the following packages
    * mysql-server
    * redis-server
    * ruby-dev
 
 
 

* install [Phusion Passenger](https://www.phusionpassenger.com/library/install/nginx/install/oss/xenial/) from the official repo

## create a database and a user
```
mysql -u root -p
CREATE DATABASE idb;
GRANT ALL ON idb.* TO 'idb'@'localhost' IDENTIFIED BY '<somepassword>';
FLUSH PRIVILEGES;
```

* set the database configuration in /opt/the-idb/config/database.yml

## Install a LDAP server

* if you are not using an foreign LDAP server, you have to install one: `apt install slapd ldapvi ldap-utils`
* add a basic user to your LDAP: `ldapvi --discover -D cn=admin,dc=vm,dc=office,dc=bytemine,dc=net` (or what else your DN is)

```
add ou=Users,dc=vm,dc=office,dc=bytemine,dc=net
objectClass: organizationalUnit
objectClass: top
ou: Users

add cn=testuser1,ou=Users,dc=vm,dc=office,dc=bytemine,dc=net
objectClass: top
objectClass: person
objectClass: organizationalPerson
objectClass: inetOrgPerson
cn: testuser1
givenName: Tim
sn: Tester
uid: testuser1
userPassword: {SSHA} somehash
```

* the password can be generated with `slappasswd -h {SSHA} -s somepassword`
* configure the LDAP access in /opt/the-idb/config/application.yml

## create an user and group

`useradd --user-group idb --home /opt/the-idb --no-create-home`

## change owner and group

`chown -R idb.idb /opt/the-idb`

## install  RVM

* go to the [RVM](https://rvm.io/) website and install RVM
* add idb to the rvm group `adduser idb rvm`
* enter a shell for user idb `sudo -u idb -H /bin/bash`
* enter /opt/the-idb `cd /opt/the-idb` 
* run the following commands for installing ruby 2.2.4:
```
source /etc/profile.d/rvm.sh
rvm autolibs disable
rvm install ruby-2.2.4
rvm use --default ruby-2.2.4
```

## install bundler and gems

```
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

### /etc/apache2/sites-available/idb.conf

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
        ServerName idb.example.com
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
   PassengeGroup idb
# and all the other regular ssl options like certificate etc. pp.
</VirtualHost>
```

* run `a2ensite idb && apache2ctl graceful`

### /etc/init/idb-sidekiq.conf

```
description "idb-sidekiq" 

start on (local-filesystems and net-device-up IFACE=lo and runlevel [2345])
stop on runlevel [!2345]

respawn
chdir /opt/the-idb

console log
setuid idb
setgid idb

env LANG=en_US.UTF-8
env RAILS_ENV="production" 
sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games

exec ruby -S bundle exec sidekiq -L log/sidekiq.log
```

* reload upstart: `initctl reload-configuration`
* start sidekiq: `service idb-sidekiq start`
