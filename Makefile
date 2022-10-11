MAKEFLAGS += --warn-undefined-variables
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
.DEFAULT_GOAL := help
.SUFFIXES:

ALL_TARGETS := $(shell egrep -o ^[0-9A-Za-z_-]+: $(MAKEFILE_LIST) | sed 's/://')

.PHONY: $(ALL_TARGETS)

all: check_for_image_updates update_lockfile shellcheck shfmt hadolint rubocop build rspec ## Check for updates, lint, build, and test
	@:

backup: ## Backup database and web access logs
	@echo -e "\033[36m$@\033[0m"
	@./backup.sh

build: ## Build an image from a Dockerfile
	@echo -e "\033[36m$@\033[0m"
	@./tools/build.sh docker.io/shakiyam/bbs

check_for_image_updates: ## Check for image updates
	@echo -e "\033[36m$@\033[0m"
	@./tools/check_for_image_updates.sh "$(shell awk -e '/FROM/{print $$2}' Dockerfile)" docker.io/ruby:alpine

clean: ## Stops containers and removes containers, networks, volumes, and images
	@echo -e "\033[36m$@\033[0m"
	@./tools/docker-compose-wrapper.sh down -v
	@./tools/remove_images.sh docker.io/shakiyam/bbs

hadolint: ## Lint Dockerfile
	@echo -e "\033[36m$@\033[0m"
	@./tools/hadolint.sh Dockerfile

help: ## Print this help
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[0-9A-Za-z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

restart: backup stop start ## Restart the application

rspec: start ## Test the applicattion
	@echo -e "\033[36m$@\033[0m"
	@NETWORK=bbs-default ./tools/capybara.sh

rubocop: ## Lint Ruby scripts
	@echo -e "\033[36m$@\033[0m"
	@./tools/rubocop.sh

shellcheck: ## Lint shell scripts
	@echo -e "\033[36m$@\033[0m"
	@./tools/shellcheck.sh *.sh tools/*.sh

shfmt: ## Lint shell scripts
	@echo -e "\033[36m$@\033[0m"
	@./tools/shfmt.sh -l -d -i 2 -ci -bn *.sh tools/*.sh

start: ## Start the application
	@echo -e "\033[36m$@\033[0m"
	@./tools/docker-compose-wrapper.sh up -d
	@./tools/wait-to-get-healthy.sh bbs-db
	@./tools/wait-to-get-healthy.sh bbs-web

stop: backup ## Stop the application
	@echo -e "\033[36m$@\033[0m"
	@./tools/docker-compose-wrapper.sh stop

update_lockfile: ## Update Gemfile.lock
	@echo -e "\033[36m$@\033[0m"
	@./tools/update_lockfile.sh
