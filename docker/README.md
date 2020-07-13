# dockerized idb

NB: this isn't polished and production ready yet.

`Dockerfile` and `docker-compose.yml`, facilitate running the
idb as container. the following containers are used:

- app: running the idb with apache & passenger
- sidekiq: same image as idb, different command run
- mysql: database, with ./runtime/data/mysql mounted for database persistance
  this location can be changed in `docker-compose.yml`
- redis: sidekiq requirement
- ldap: user authentication, changes aren't saved as there is no
        volume mounted
- stomp: activemq queue for maintenance log handling

## building the container

in this directory run:
	
	docker build -t idb -f Dockerfile ..

to build with another ruby version, change 

	ARG ruby_version=2.6.3

at the beginning of `Dockerfile` to something ruby-build understands. there
are similar switches for the version of ruby-build itself and the bundler used.
the idb image is build from `debian:buster-slim`, as i've had problems getting
the passenger or ruby images to work correctly.

the container is created to use passenger with apache and a single ruby version
build/installed by ruby-build. it is a "dual-use" container, it can be used to
run the idb or the matching sidekiq. see docker-compose.yml for details.

## configuration

### environment variables

the basic settings can be configured using environment variables:

_note: it should be fine to just rename the `*.env.example` files, dropping `.example`
to have a working instance._

edit `runtime/environments/idb.env.example` changing values where appropriate
and save it to `idb.env` . if you use the mysql and docker containers defined
in `docker-compose.yml`, there are similar files `ldap.env.example` and
`mysql.env.example` which are used for these containers. the ldap container is
bootstrapped by `runtime/bootstrap.ldif`.

### modifing the config

the config at `runtime/config` is mounted as volume into the container, so if
you want to customize further, you can modify it as you like.

for details about the other containers, see:

https://github.com/osixia/docker-openldap
https://hub.docker.com/_/mysql/
https://hub.docker.com/_/redis/
https://github.com/vromero/activemq-artemis-docker/

## running with `docker-compose`

if you want to use a containerized database and redis,
you can use 

	docker-compose up -d 

this will start containers for mysql, ldap, redis, sidekiq and the idb.

on first run the database is initialized by the `build/idb.sh` script:

	bundle exec rake db:schema:load >/dev/null 2>&1 || true

this _should_ be safe but i'll have to investigate a bit more if there
aren't conditions where this might delete data.

any of the redis, mysql, ldap or stomp containers are replaceable by
modifying `idb.env` to use other systems. the only requirement
are the sidekiq and app containers.

