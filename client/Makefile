check: check-pre-push
	yarn build

check-pre-push:
	yarn lint

dev:
	yarn dev

install:
	yarn install

prod-build:
	rm -rf .next/standalone
	NODE_ENV=production yarn build
	cp -r .next/static .next/standalone/.next

prod:
	PORT=3002 HOSTNAME="0.0.0.0" node .next/standalone/server.js

watch: compile
	yarn run compile -w
