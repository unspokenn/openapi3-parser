#!/usr/bin/env just --justfile

package_name := `sed -En 's/name[[:space:]]*=[[:space:]]*"([^"]+)"/\1/p' Cargo.toml | head -1`
package_version := `sed -En 's/version[[:space:]]*=[[:space:]]*"([^"]+)"/\1/p' Cargo.toml | head -1`

set dotenv-load := false

update-sub:
    git submodule update --remote --merge

help:
    @just --list --unsorted

build:
    cargo build
alias b := build

run *args:
    cargo run {{args}}
alias r := run

release:
    cargo build --release

install:
    cargo install --path .

test *args:
    cargo test {{args}}

check:
    cargo check
alias c := check

fix:
    cargo clippy --fix

# Bump version. level=major,minor,patch
version level:
    git diff-index --exit-code HEAD > /dev/null || ! echo You have untracked changes. Commit your changes before bumping the version.
    cargo set-version --bump {{level}}
    cargo update # This bumps Cargo.lock
    VERSION=$(rg  "version = \"([0-9.]+)\"" -or '$1' Cargo.toml | head -n1) && \
        git commit -am "Bump version {{level}} to $VERSION" && \
        git tag v$VERSION && \
        git push origin v$VERSION
    git push

publish:
    cargo publish

patch: test
    just version patch
    just publish
