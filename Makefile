build:
	make -C backend build
	make -C frontend build

check:
	make -C backend check
	make -C frontend check

dev:
	ultraman start -f Procfile.dev

e2e:
	ps ax | grep frontend | grep -v grep >/dev/null || ( echo "app not started" ; false )
	make -C frontend e2e

start: build
	ultraman start

test:
	make -C frontend test
