# Install instructions for The IDB on Ubuntu 18.04

* clone the repo into /opt/the-idb

## create the config directory

* copy config-example/ to somewhere else and symlink it to config/
```
$ cd /opt/the-idb/
$ sudo cp -r config-example /etc/the-idb
$ ln -s /etc/the-idb config
```

* install the following packages
    * apache2
	* apache2-dev
    * mysql-server
    * redis-server
    * ruby-dev
    * libmysqld-dev
    * build-essential
 
* install [Phusion Passenger](https://www.phusionpassenger.com/library/install/nginx/install/oss/bionic/) from the official repo

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
* for further infos on the user handling see ldap-and-usermanagement.md

Be aware that without configuring ldap for user authentication you will not be able
to use the idb.

## create an user and group

`useradd --user-group idb --home /opt/the-idb --no-create-home`

## change owner and group

`chown -R idb.idb /opt/the-idb`

## install  RVM

* go to the [RVM](https://rvm.io/) website and install RVM
* add idb to the rvm group `adduser idb rvm`
* enter /opt/the-idb `cd /opt/the-idb` 
* run the following commands for installing ruby 2.2.4:
```
source /etc/profile.d/rvm.sh

rvm install ruby-2.4.1
rvm use --default ruby-2.4.1
```

## adjust the Gemfile

The Gemfile needs to be adjusted, since for all other platforms the idb currently still uses ruby 2.2.4.

Edit `Gemfile` and replace the 'ruby-2.2.4` line so it looks like in this extract:

```
 source 'https://rubygems.org'

 ruby '2.4.1'
 gem 'rails'
```

## install bundler and gems

* enter a shell for user idb `sudo -u idb -H /bin/bash`

```
source /etc/profile.d/rvm.sh
gem install bundler
RAILS_ENV=production bundle install
```
* setup rvm wrapper for sidekiq `rvm wrapper current bootup sidekiq`


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

* enable SSL for apache: `a2enmod ssl`

* enabke the newly created site by running `a2ensite idb` and then restart apache: apache2ctl graceful`

### /etc/systemd/system/sidekiq.service
```
[Unit]
Description=The IDB sidekiq service
After=syslog.target network.target remote-fs.target

[Service]
Type=simple
WorkingDirectory=/opt/the-idb/
Environment="RAILS_ENV=production"
ExecStart=/usr/local/rvm/bin/bootup_sidekiq -L /opt/the-idb/log/sidekiq.log
User=idb
Group=idb

[Install]
WantedBy=multi-user.target

```

* reload systemd: `systemctl daemon-reload`
* enable and start sidekiq: `systemctl enable sidekiq && systemctl start sidekiq`

## configure config/secrets.yml

You need to configure the secretes file. Open `config/secrets.yml` in your editor and
put the following (with a unique secret) there:

```
production:
        secret_key_base: Piah8pohjiheegeu9Sha
```

