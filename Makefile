MAKEFLAGS += --no-builtin-rules
MAKEFLAGS += --warn-undefined-variables
SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c
ALL_TARGETS := $(shell grep -E -o ^[0-9A-Za-z_-]+: $(MAKEFILE_LIST) | sed 's/://')
.PHONY: $(ALL_TARGETS)
.DEFAULT_GOAL := help

all: check_for_updates lint build dive trivy rspec ## Check updates, lint, build, scan image, and test

backup: ## Backup database and web access logs
	@echo -e "\033[36m$@\033[0m"
	@./backup.sh

build: ## Build Docker image
	@echo -e "\033[36m$@\033[0m"
	@./tools/build.sh ghcr.io/shakiyam/bbs

check_for_image_updates: ## Check for image updates
	@echo -e "\033[36m$@\033[0m"
	@./tools/check_for_image_updates.sh "$(shell awk -e 'NR==1{print $$2}' Dockerfile)" public.ecr.aws/docker/library/ruby:slim
	# @./tools/check_for_image_updates.sh "$(shell awk -e '/image:/&&/mysql/{print $$2}' compose.yaml)" container-registry.oracle.com/mysql/community-server:latest

check_for_library_updates: ## Check for library updates
	@echo -e "\033[36m$@\033[0m"
	@./tools/update_lockfile.sh

check_for_action_updates: ## Check for GitHub Actions updates
	@echo -e "\033[36m$@\033[0m"
	@./tools/check_for_action_updates.sh actions/checkout
	@./tools/check_for_action_updates.sh docker/build-push-action
	@./tools/check_for_action_updates.sh docker/login-action
	@./tools/check_for_action_updates.sh docker/setup-buildx-action
	@./tools/check_for_action_updates.sh docker/setup-qemu-action
	@./tools/check_for_action_updates.sh hadolint/hadolint-action '.+'

check_for_new_release: ## Check for new release
	@echo -e "\033[36m$@\033[0m"
	@./tools/check_for_new_release.sh twbs/bootstrap "$(shell grep -o 'bootstrap@[^\/]*' views/index.slim | awk -F'@' 'NR==1{printf "v%s", $$2}')"

check_for_updates: check_for_action_updates check_for_image_updates check_for_library_updates check_for_new_release ## Check for updates to all dependencies

clean: ## Stops containers and removes containers, networks, volumes, and images
	@echo -e "\033[36m$@\033[0m"
	@./tools/docker-compose-wrapper.sh down -v
	@./tools/remove_images.sh ghcr.io/shakiyam/bbs

clean_db: start ## Cleanup database by truncating posts table
	@echo -e "\033[36m$@\033[0m"
	@echo "TRUNCATE TABLE posts;" | ./mysql.sh 2>/dev/null || true

dive: build ## Analyze Docker image layers
	@echo -e "\033[36m$@\033[0m"
	@./tools/dive.sh --ci ghcr.io/shakiyam/bbs | sed '/Inefficient Files:/,/Results:/{/Results:/!d}'

dockerfmt: ## Format Dockerfile
	@echo -e "\033[36m$@\033[0m"
	@./tools/dockerfmt.sh -i 2 -n Dockerfile | diff -u --color=always Dockerfile - || true

hadolint: ## Lint Dockerfile
	@echo -e "\033[36m$@\033[0m"
	@./tools/hadolint.sh Dockerfile

help: ## Print this help
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} /^[0-9A-Za-z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

lint: hadolint dockerfmt markdownlint rubocop shellcheck shfmt ## Run all linting (hadolint, dockerfmt, markdownlint, rubocop, shellcheck, shfmt)

markdownlint: ## Lint Markdown files
	@echo -e "\033[36m$@\033[0m"
	@./tools/markdownlint-cli2.sh "*.md"

restart: backup stop start ## Restart with backup

rspec: clean_db ## Test the application
	@echo -e "\033[36m$@\033[0m"
	@NETWORK=host ./tools/capybara.sh

rubocop: ## Lint Ruby scripts
	@echo -e "\033[36m$@\033[0m"
	@./tools/rubocop.sh

shellcheck: ## Lint shell scripts
	@echo -e "\033[36m$@\033[0m"
	@./tools/shellcheck.sh ./*.sh tools/*.sh

shfmt: ## Lint shell script formatting
	@echo -e "\033[36m$@\033[0m"
	@./tools/shfmt.sh -l -d -i 2 -ci -bn ./*.sh tools/*.sh

start: ## Start containers and wait for health checks
	@echo -e "\033[36m$@\033[0m"
	@./tools/docker-compose-wrapper.sh up -d
	@./tools/wait-to-get-healthy.sh bbs-db
	@./tools/wait-to-get-healthy.sh bbs-web

stop: backup ## Stop containers (includes backup)
	@echo -e "\033[36m$@\033[0m"
	@./tools/docker-compose-wrapper.sh stop

trivy: build ## Scan Docker image for vulnerabilities
	@echo -e "\033[36m$@\033[0m"
	@./tools/trivy.sh image --quiet --severity HIGH,CRITICAL --ignore-unfixed --exit-code 1 ghcr.io/shakiyam/bbs | sed -n '/^Total:/,$$p'
