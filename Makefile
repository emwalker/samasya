build: install
	make -C backend build
	make -C frontend build

check:
	make -C backend check
	make -C frontend check

dev: stop
	pm2 start dev.config.yaml
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

logs:
	pm2 logs

setup:
	npm install pm2 -g

start: build stop
	pm2 start prod.config.yaml
	pm2 logs

stop:
	pm2 kill

test:
	make -C backend test
