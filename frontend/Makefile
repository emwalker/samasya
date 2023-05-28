build:
	npm run build

e2e:
	npm run cypress run --headless

dev:
	npm run dev

check: check-pre-push
	rm -rf node_modules
	npm install

check-pre-push:
	npm run lint

fix:
	npm run lint -- --fix

install:
	npm install

lint:
	npm run lint --fix

start:
	npm run start
