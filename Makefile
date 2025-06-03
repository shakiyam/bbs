MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --warn-undefined-variables
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
ALL_TARGETS := $(shell grep -E -o ^[0-9A-Za-z_-]+: $(MAKEFILE_LIST) | sed 's/://')
.PHONY: $(ALL_TARGETS)
.DEFAULT_GOAL := help

all: check_for_updates lint build rspec ## Check for updates, lint, build, and test

backup: ## Backup database and web access logs
	@echo -e "\033[36m$@\033[0m"
	@./backup.sh

build: ## Build an image from a Dockerfile
	@echo -e "\033[36m$@\033[0m"
	@./tools/build.sh ghcr.io/shakiyam/bbs

check_for_image_updates: ## Check for image updates
	@echo -e "\033[36m$@\033[0m"
	@./tools/check_for_image_updates.sh "$(shell awk -e 'NR==1{print $$2}' Dockerfile)" public.ecr.aws/docker/library/ruby:slim
	# @./tools/check_for_image_updates.sh "$(shell awk -e '/image:/&&/mysql/{print $$2}' compose.yaml)" container-registry.oracle.com/mysql/community-server:latest

check_for_library_updates: ## Check for library updates
	@echo -e "\033[36m$@\033[0m"
	@./tools/update_lockfile.sh

check_for_new_release: ## Check for new release
	@echo -e "\033[36m$@\033[0m"
	@./tools/check_for_new_release.sh twbs/bootstrap "$(shell grep -o 'bootstrap@[^\/]*' views/index.slim | awk -F'@' 'NR==1{printf "v%s", $$2}')"
	@./tools/check_for_new_release.sh actions/checkout "$(shell grep -o 'actions/checkout@[^\/]*' .github/workflows/lint_and_build.yml | awk -F'@' 'NR==1{printf "%s", $$2}')" '(v[0-9]+)'
	@./tools/check_for_new_release.sh docker/build-push-action "$(shell grep -o 'docker/build-push-action@[^\/]*' .github/workflows/lint_and_build.yml | awk -F'@' 'NR==1{printf "%s", $$2}')" '(v[0-9]+)'
	@./tools/check_for_new_release.sh docker/login-action "$(shell grep -o 'docker/login-action@[^\/]*' .github/workflows/lint_and_build.yml | awk -F'@' 'NR==1{printf "%s", $$2}')" '(v[0-9]+)'
	@./tools/check_for_new_release.sh docker/setup-buildx-action "$(shell grep -o 'docker/setup-buildx-action@[^\/]*' .github/workflows/lint_and_build.yml | awk -F'@' 'NR==1{printf "%s", $$2}')" '(v[0-9]+)'
	@./tools/check_for_new_release.sh docker/setup-qemu-action "$(shell grep -o 'docker/setup-qemu-action@[^\/]*' .github/workflows/lint_and_build.yml | awk -F'@' 'NR==1{printf "%s", $$2}')" '(v[0-9]+)'
	@./tools/check_for_new_release.sh hadolint/hadolint-action "$(shell grep -o 'hadolint/hadolint-action@[^\/]*' .github/workflows/lint_and_build.yml | awk -F'@' 'NR==1{printf "%s", $$2}')"

check_for_updates: check_for_image_updates check_for_library_updates check_for_new_release ## Check for updates to all dependencies

clean: ## Stops containers and removes containers, networks, volumes, and images
	@echo -e "\033[36m$@\033[0m"
	@./tools/docker-compose-wrapper.sh down -v
	@./tools/remove_images.sh ghcr.io/shakiyam/bbs

hadolint: ## Lint Dockerfile
	@echo -e "\033[36m$@\033[0m"
	@./tools/hadolint.sh Dockerfile

help: ## Print this help
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[0-9A-Za-z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

lint: hadolint rubocop shellcheck shfmt ## Lint all dependencies

restart: backup stop start ## Restart the application

rspec: start ## Test the applicattion
	@echo -e "\033[36m$@\033[0m"
	@NETWORK=host ./tools/capybara.sh

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
