check:
	$(MAKE) -C api check
	$(MAKE) -C client check

check-pre-push: lint
	$(MAKE) -C api check
	$(MAKE) -C client check-pre-push
	$(MAKE) prod-build
	$(MAKE) git-no-changes

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
	sqlite3 api/development.db < api/src/fixtures/seeds.sql

migrate:
	$(MAKE) -C api migrate

prod-build:
	$(MAKE) -C api prod-build
	$(MAKE) -C client prod-build

prod:
	overmind start -f Procfile.prod

save:
	sqlite3 api/development.db .dump > api/src/fixtures/seeds.sql

test:
	$(MAKE) -C api test
