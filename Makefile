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
	sed -i "" "s/^version = .*/version = \"$$version\"/" Cargo.toml

push: ## Git commit + push
	@read -p "Commit message: " commit_message; \
		git add --all; \
		git commit -m "$$commit_message"
	@git push -u origin main

push_new_release: ## Version bump + Git tags last commit + push
	@make bump

	@if git tag -l v$$(cargo pkgid | cut -d# -f2) | grep -q v$$(cargo pkgid | cut -d# -f2); then \
		echo "This tag version already exists !"; \
		exit 1; \
	fi

	@if ! git diff --quiet --exit-code; then \
		read -p "Some changes are not staged. Do you want to git add them first? (Enter=Yes | n=No) " git_stage; \
		if [ "$$git_stage" = "yes" ] || [ "$$git_stage" = "y" ] || [ -z "$$git_stage" ]; then \
			git add --all; \
		fi \
	fi

	@if ! git diff --cached --quiet --exit-code; then \
		read -p "Staging is not committed. Do you want to git commit first? (Enter=Yes | n=No) " git_commit; \
		if [ "$$git_commit" = "yes" ] || [ "$$git_commit" = "y" ] || [ -z "$$git_commit" ]; then \
			read -p "Commit message: " commit_message; git commit -m "$$commit_message"; \
		fi \
	fi

	@if ! git diff --quiet main..origin/main; then \
		read -p "Local main branch is not synced with Remote main. Do you want to git push? (Enter=Yes | n=No) " git_push; \
		if [ "$$git_push" = "yes" ] || [ "$$git_push" = "y" ] || [ -z "$$git_push" ]; then \
			git push -u origin main; \
		fi \
	fi

	@git tag v$$(cargo pkgid | cut -d# -f2)
	@git push -u origin v$$(cargo pkgid | cut -d# -f2)


git_status:
	@if ! git diff --quiet --exit-code; then \
		read -p "Some changes are not staged. Do you want to git add them first? (Enter=Yes | n=No) " git_stage; \
		if [ "$$git_stage" = "yes" ] || [ "$$git_stage" = "y" ] || [ -z "$$git_stage" ]; then \
			echo "TEST"; \
		fi \
	fi


	@if ! git diff --quiet --exit-code; then \
		echo "Some changes are not staged (git add/rm)"; \
	fi
	@if ! git diff --cached --quiet --exit-code; then \
		echo "Staging is not committed (git commit)"; \
	fi
	@if ! git diff --quiet main..origin/main; then \
		echo "Local main branch is not synced with Remote main (git push)"; \
	fi

