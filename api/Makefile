check: lint test

dev:
	cargo run --bin api

fix:
	cargo clippy --fix --allow-dirty --allow-staged

lint:
	cargo clippy -- -D warnings

prod:
	./target/release/api

prod-build:
	cargo build --release --bin api

test:
	cargo test
