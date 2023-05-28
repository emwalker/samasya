build: install
	make -C backend build
	make -C frontend build

check:
	make -C backend check
	make -C frontend check

check-pre-push:
	make -C backend check
	make -C frontend check-pre-push

dev: stop
	pm2 start development.config.yaml
	pm2 logs

e2e:
	ps ax | grep frontend | grep -v grep >/dev/null || ( echo "app not started" ; false )
	make -C frontend e2e

fix:
	make -C backend fix
	make -C frontend fix

install:
	make -C frontend install

lint:
	make -C frontend lint

load:
	rm -f backend/development.db
	sqlite3 backend/development.db < data/fixtures.sql

logs:
	pm2 logs

save:
	sqlite3 backend/development.db .dump > data/fixtures.sql

setup:
	npm install pm2 -g

start: build stop
	pm2 start production.config.yaml --wait-ready
	pm2 logs

stop:
	pm2 kill

test:
	make -C backend test
