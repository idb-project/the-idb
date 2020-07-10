# dockerized idb

NB: this isn't polished yet.

`Dockerfile` and `docker-compose.yml`, facilitate running the
idb as container. the following containers are used:

- app: running the idb with apache & passenger
- sidekiq: same image as idb, different command run
- mysql: database, with ./runtime/data/mysql mounted for database persistance
  this location can be changed in `docker-compose.yml`
- redis: sidekiq requirement
- ldap: user authentication, changes aren't saved as there is no
        volume mounted

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

edit `runtime/environments/idb.env.example` changing values where appropriate
and save it to `idb.env` . if you use the mysql and docker containers defined
in `docker-compose.yml`, there are similar files `ldap.env.example` and
`mysql.env.example` which are used for these containers. the ldap container is
bootstrapped by `runtime/bootstrap.ldif`.

for details about the other containers, see:

https://github.com/osixia/docker-openldap
https://hub.docker.com/_/mysql/
https://hub.docker.com/_/redis/

## running with `docker-compose`

if you want to use a containerized database and redis,
you can use 

	docker-compose up -d 

this will start containers for mysql, ldap, redis, sidekiq and the idb.
you'll have to initialize the database on first run, do so by running

	docker-compose exec app bash -lc 'bundle exec rake db:schema:load'

after starting the containers with `docker-compose`.

any of the redis or mysql containers should be replaceable by
modifying `idb.env` to use other systems. the only requirement
are the sidekiq and app containers.

