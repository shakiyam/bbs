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
	@./tools/build.sh shakiyam/bbs

clean: ## Stops containers and removes containers, networks, volumes, and images
	@echo -e "\033[36m$@\033[0m"
	@./tools/docker-compose-wrapper.sh down -v
	@./tools/remove_images.sh shakiyam/bbs

hadolint: ## Lint Dockerfile
	@echo -e "\033[36m$@\033[0m"
	@./tools/hadolint.sh Dockerfile

help: ## Print this help
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[0-9A-Za-z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

rspec: build ## Test the applicattion
	@echo -e "\033[36m$@\033[0m"
	@./tools/docker-compose-wrapper.sh up -d
	@./tools/wait-to-get-healthy.sh bbs_db_1
	@./tools/wait-to-get-healthy.sh bbs_web_1
	@./tools/capybara.sh

rubocop: ## Lint Ruby scripts
	@echo -e "\033[36m$@\033[0m"
	@./tools/rubocop.sh

shellcheck: ## Lint shell scripts
	@echo -e "\033[36m$@\033[0m"
	@./tools/shellcheck.sh *.sh tools/*.sh

shfmt: ## Lint shell scripts
	@echo -e "\033[36m$@\033[0m"
	@./tools/shfmt.sh -l -d -i 2 -ci -bn *.sh tools/*.sh

update_lockfile: ## Update Gemfile.lock
	@echo -e "\033[36m$@\033[0m"
	@./tools/update_lockfile.sh
