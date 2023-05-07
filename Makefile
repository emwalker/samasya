build:
	make -C backend build
	make -C frontend build

check:
	make -C frontend lint

dev:
	ultraman start -f Procfile.dev

start:
	ultraman start
