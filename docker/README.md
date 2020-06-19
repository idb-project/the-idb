# dockerized idb

this, together with `../Dockerfile` and `../docker-compose.yml`, facilitates
running the idb as container. the following containers are used:

- app: running the idb with apache & passenger
- sidekiq: same image as idb, different command run
- mysql: database, with ./mysql mounted for database persistance
  this location can be changed in `docker-compose.yml`
- redis: sidekiq requirement

## building the container

in the parent directory (which contains `Dockerfile`) run:

	docker build -t idb .

to build with another ruby version, change 

	ARG ruby_version=ruby-2.6.3

at the beginning of `Dockerfile` to something rvm understands. the idb
image is build from `debian:buster-slim`, as i've had problems getting
the passenger images to work. 

the container is created to use passenger with apache and rvm for installing
the right ruby versions. eventually rvm could be replaced by something
which is a better fit for production, but in a container environment this
should be ok for now.

## configuration

edit `idb.env.example` changing values where appropriate
and save it to `idb.env` .

## running with `docker-compose`

if you want to use a containerized database and redis,
you can use 

	docker-compose up -d 

in the parent directory. this will start containers for mysql, redis,
sidekiq and the idb. you'll have to initialize the database on first run,
do so by running

	docker-compose exec app bash -lc 'bundle exec rake db:schema:load'

after starting the containers.

any of the redis or mysql containers should be replaceable by
modifying `idb.env` to use other systems. the only requirements
are the sidekiq and app containers.

