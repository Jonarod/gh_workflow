SHELL := /bin/bash
TARGETS := x86_64-unknown-linux-gnu aarch64-apple-darwin
PROJECT_NAME := $(shell grep 'name\s*=\s*.*' Cargo.toml | awk -F\" '{print $$2}')

.PHONY: help

help:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'


get_name: ## Get name of project
	@echo "Project Name: $(PROJECT_NAME)"

bump: ## Bump the version number
	@echo "Current version is $(shell cargo pkgid | cut -d# -f2)"
	@read -p "Enter new version number: " version; \
	updated_version=$$(cargo pkgid | cut -d# -f2 | sed -E "s/([0-9]+\.[0-9]+\.[0-9]+)$$/$$version/"); \
	sed -i -E "s/^version = .*/version = \"$$updated_version\"/" Cargo.toml
	@echo "New version is $(shell cargo pkgid | cut -d# -f2)"%

push: ## Git push a new commit
	@git add .
	@read -p "Commit message: " commit_message; git commit -m "$$commit_message"
	@git push -u origin main

push_new_release: ## Git push as a new release
	@# echo v$(shell cargo pkgid | cut -d# -f2)
	@# make bump
	@make push
	@git tag v$(shell cargo pkgid | cut -d# -f2)
	@git push -u origin v$(shell cargo pkgid | cut -d# -f2)
