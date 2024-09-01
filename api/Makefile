check: lint test

dev:
	cargo run --bin api

lint:
	cargo fmt
	cargo clippy --fix --allow-dirty --allow-staged
	cargo clippy -- -D warnings

prod:
	./target/release/api

prod-build:
	cargo build --release --bin api

test:
	cargo test
