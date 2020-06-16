# dockerized idb

## building the container

in the parent directory (which contains the Dockerfile) run:

	docker build -t idb .

## configuration

edit `idb.env.example` changing values where appropriate
and save it to `idb.env` .

## running with `docker-compose`

if you want to use a containerized database and redis,
you can use 

	docker-compose up -d 

in the parent directory. this will start containers for mysql, redis
and the idb. you'll have to initialize the database on first run,
do so by running

	docker-compose exec app bash -lc 'bundle exec rake db:schema:load'

after starting the containers.
