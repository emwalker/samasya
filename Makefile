check:
	$(MAKE) -C api check
	$(MAKE) -C client check

check-pre-push: lint git-no-changes
	$(MAKE) -C api check
	$(MAKE) -C client check-pre-push
	$(MAKE) prod-build

dev:
	overmind start -f Procfile.dev

fix:
	$(MAKE) -C api fix
	$(MAKE) -C client fix

git-no-changes:
	bash -c '[[ -z "$(shell git status -s -uall)" ]]'

install:
	$(MAKE) -C client install

lint:
	$(MAKE) -C api lint

load:
	rm -f api/development.db
	sqlite3 api/development.db < data/fixtures.sql

prod-build:
	$(MAKE) -C api prod-build
	$(MAKE) -C client prod-build

prod:
	overmind start -f Procfile.prod

save:
	sqlite3 api/development.db .dump > data/fixtures.sql

test:
	$(MAKE) -C api test
