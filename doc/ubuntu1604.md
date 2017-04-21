# Example install on Ubuntu 16.04

## Basic requirements

* MySQL Server
** mysql-server, libmysqlclient-dev
* LDAP or ActiveDirectory
** slapd
* Redis (>= 2.8)
** redis-server
* Ruby 2.2
** for example via rvm (http://rvm.io)

Likely the following in order to get everything up and running:

* curl
* git

## Start setting up

* Install the gems needed for the core application
$ gem install bundler
$ bundle install

* create database user within MySQL

* create an example config
$ mv config-example config

* adjust config/database.yml to suit your needs

* fill the database with the base schema
$ bundle exec rake db:schema:load

* if there is no directory service in place, setup a local openldap
** see LDAP.md for details

