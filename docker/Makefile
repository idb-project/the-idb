skip:
	echo -n

image:
	docker build -t idb -f Dockerfile ..

dist/idb-image.tar.gz: image
	docker save idb:latest | gzip > dist/idb-image.tar.gz

dist/idb-docker.tar.gz: dist/idb-image.tar.gz docker-compose.yml runtime/environments/idb.env.example runtime/environments/mysql.env.example runtime/environments/ldap.env.example
	tar cvzf $@ $^

