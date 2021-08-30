MAKEFLAGS += --warn-undefined-variables
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help
.SUFFIXES:

ALL_TARGETS := $(shell egrep -o ^[0-9A-Za-z_-]+: $(MAKEFILE_LIST) | sed 's/://')

.PHONY: $(ALL_TARGETS)

all: shellcheck shfmt hadolint rubocop update_lockfile build rspec ## Lint, update Gemfile.lock, build, and test
	@:

build: ## Build an image from a Dockerfile
	@echo -e "\033[36m$@\033[0m"
	@./build.sh

clean: ## Stops containers and removes containers, networks, volumes, and images
	@echo -e "\033[36m$@\033[0m"
	@./docker-compose-wrapper.sh down -v
	@./remove_images.sh

hadolint: ## Check for Dockerfile
	@echo -e "\033[36m$@\033[0m"
	@./hadolint.sh Dockerfile

rspec: build ## Test the applicattion
	@echo -e "\033[36m$@\033[0m"
	@./docker-compose-wrapper.sh up -d
	@./wait-to-get-healthy.sh bbs_db_1
	@./wait-to-get-healthy.sh bbs_web_1
	@./capybara.sh

rubocop: ## Check for Ruby scripts
	@echo -e "\033[36m$@\033[0m"
	@./rubocop.sh

shellcheck: ## Lint shell scripts
	@echo -e "\033[36m$@\033[0m"
	@./shellcheck.sh *.sh

shfmt: ## Lint shell scripts
	@echo -e "\033[36m$@\033[0m"
	@./shfmt.sh -l -d -i 2 -ci -bn *.sh

update_lockfile: ## Update Gemfile.lock
	@echo -e "\033[36m$@\033[0m"
	@./update_lockfile.sh

help: ## Print this help
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[0-9A-Za-z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
