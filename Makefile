check:
	make -C api check
	make -C client check

check-pre-push:
	make -C api check
	make -C client check-pre-push

dev:
	overmind start -f Procfile.dev

fix:
	make -C api fix
	make -C client fix

install:
	make -C client install

lint:
	make -C client lint

load:
	rm -f api/development.db
	sqlite3 api/development.db < data/fixtures.sql

prod-build:
	make -C api prod-build
	make -C client prod-build

prod:
	overmind start -f Procfile.prod

save:
	sqlite3 api/development.db .dump > data/fixtures.sql

test:
	make -C api test
