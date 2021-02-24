#!/usr/bin/env bash
set -x
set -e
sudo service mysql stop || echo "mysql not stopped"
sudo stop mysql-5.7 || echo "mysql-5.7 not stopped"
sudo  mysqld_safe --skip-grant-tables &
sleep 4
sudo mysql -e "use mysql; update user set authentication_string=PASSWORD('') where User='root'; update user set plugin='mysql_native_password';FLUSH PRIVILEGES;"
sudo kill -9 `sudo cat /var/lib/mysql/mysqld_safe.pid` || echo "mysqld_safe.pid not found"
sudo kill -9 `sudo cat /var/run/mysqld/mysqld.pid` || echo "mysqld.pid not found"
sudo service mysql restart
sleep 4
