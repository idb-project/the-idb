# Install instructions for The IDB on CentOS 7


* clone the repo into /opt/the-idb

## create the config directory

* copy config-example/ to somewhere else and symlink it to config/
```
$ cd /opt/the-idb/
$ sudo cp config-example /etc/the-idb
$ ln -s /etc/the-idb config
```

## package / repo prerequisites

* install epel-release and enable the epel repo
* install the following packages
	* git
	* ruby-devel
	* redis

* enable and start redis `systemctl enable redis  && systemctl start redis`

 
 * install [Phusion Passenger](https://www.phusionpassenger.com/library/install/apache/install/oss/el7/) from the official repo

 
## install and setup mysql
* install the mysql 5.7 repo 
```
yum localinstall -y https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm
```
* and the following packages from there
	* mysql-community-server
  	* mysql-community-devel
* enable and start the mysql-server `systemctl enable mysqld  && systemctl start mysqld`
* set a new mysql root password, you can find the temporary one in /var/log/mysqld.log
```
grep password /var/log/mysqld.log 
mysql -u root -p
SET PASSWORD FOR 'root'@'localhost' = PASSWORD('securepass');
CREATE DATABASE idb;
GRANT ALL ON idb.* TO 'idb'@'localhost' IDENTIFIED BY '<somepassword>';
FLUSH PRIVILEGES;
```

## Install a LDAP server

* if you are not using an foreign LDAP server, you have to install one: `yum install -y 389-ds-base 389-admin`
* run `setup-ds-admin.pl`to set it up

## configuration

* configure the LDAP access in /opt/the-idb/config/application.yml
* set the database configuration in /opt/the-idb/config/database.yml
* _Caution:_ adjust the socket to /var/lib/mysql/mysql.sock
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

```

## install bundler and gems

```
cd /opt/the-idb
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

