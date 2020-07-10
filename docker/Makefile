skip:
	echo -n

image:
	docker build -t idb -f Dockerfile ..

dist/idb-image.tar.gz: image
	docker save idb:latest | gzip > dist/idb-image.tar.gz

dist/idb-docker.tar.gz: dist/idb-image.tar.gz docker-compose.yml environments/idb.env.example environments/mysql.env.example environments/ldap.env.example
	tar cvzf $@ $^

