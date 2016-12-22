# setup idb

## Basic requirements

* MySQL Server (>= 5.7)
* LDAP or ActiveDirectory
* Redis (>= 2.8)
* Ruby 2.2
* For more than just tests a webserver (for example Apache+Passenger)

## Setup

* Copy the directory 'config-example' to 'config'
* Set up a MySQL database 'idb' and set credentials from config/database.yml
* Set up a MySQL database 'idb_test' and set credentials from config/database.yml
* Install bundler gem via `gem install bundler`
* Install packages via `sudo apt-get install libssl-dev libmysqlclient-dev`
* Install a recent (>=2.8 is needed by Sidekiq) version of redis-server e.g. from this PPA: ppa:chris-lea/redis-server
* Install some build dependencies: 'sudo apt-get install make g++'
* Bundle dependencies via `bundle install --path vendor/bundle`
* Setup database via `bundle exec rake db:schema:load`
* Start development environment via `bundle exec foreman start`

The application uses LDAP to authenticate users. To allow LDAP logins during
development on a local machine, foreman will start a small LDAP server.

There are two user accounts in the development LDAP database. (db/ldapdb.json)

* admin / smada
* john / niwdlab

## Run tests

* `bundle exec rspec`
* Automatically run tests when files change: `bundle exec guard`

### Things to think of when updating Ruby

ruby -S gem update --system
ruby -S gem install bundler --no-ri --no-rdoc
ruby -S gem install rake --no-ri --no-rdoc

