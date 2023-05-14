build:
	cargo build --release --bin backend

check: lint test

dev:
	cargo run --bin backend

fix:
	cargo clippy --fix

lint:
	cargo clippy -- -D warnings

start:
	./target/release/backend

test:
	cargo test
