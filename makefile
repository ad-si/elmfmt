.PHONY: help
help: makefile
	@tail -n +4 makefile | grep ".PHONY"


.PHONY: format
format:
	cargo clippy --fix --allow-dirty
	cargo fmt
	# nix fmt  # TODO: Reactivate when it's faster


.PHONY: test
test: format
	cargo test


.PHONY: build
build:
	cargo build


.PHONY: release
release:
	@echo '1. `cai changelog <first-commit-hash>`'
	@echo '2. `git add ./changelog.md && git commit -m "Update changelog"`'
	@echo '3. `cargo release major / minor / patch`'
	@echo '4. Create a new GitHub release at https://github.com/ad-si/elmfmt/releases/new'
	@echo -e \
		"5. Announce release on \n" \
		"   - https://x.com \n" \
		"   - https://bsky.app \n" \
		"   - https://news.ycombinator.com \n" \
		"   - https://lobste.rs \n" \
		"   - https://discourse.elm-lang.org/ \n" \
		"   - https://www.reddit.com/r/elm/ \n"


.PHONY: install
install:
	cargo install --path .
