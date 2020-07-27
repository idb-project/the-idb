skip:
	echo -n

image:
	docker build -t idb -f Dockerfile ..

dist/idb-image.tar.gz: image
	docker save idb:latest | gzip > dist/idb-image.tar.gz

dist/idb.tar.gz: dist/idb-image.tar.gz docker-compose.yml $(shell find runtime/config ) $(shell find runtime/environments) runtime/bootstrap.ldif
	tar cvzf $@ $^
