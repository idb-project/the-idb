#!/usr/bin/env bash
set -x
set -e
service mysql stop || echo "mysql not stopped"
stop mysql-5.6 || echo "mysql-5.6 not stopped"
mysqld_safe --skip-grant-tables &
sleep 4
mysql -e "use mysql; update user set authentication_string=PASSWORD('') where User='root'; update user set plugin='mysql_native_password';FLUSH PRIVILEGES;"
kill -9 `sudo cat /var/lib/mysql/mysqld_safe.pid`
kill -9 `sudo cat /var/run/mysqld/mysqld.pid`
service mysql restart
sleep 4
