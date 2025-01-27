SHELL := /bin/bash
export REPO_ROOT := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

# GitHub
GITHUB_OWNER := tprasadtp
GITHUB_REPO  := protonvpn-docker

# Define image names
DOCKER_IMAGES     := ghcr.io/$(GITHUB_OWNER)/protonvpn
DOCKER_IMAGE_URL  := ghcr.io/$(GITHUB_OWNER)/protonvpn
DOCKER_BUILDKIT   := 1
DOCKER_VULN_TYPES := os

# OCI Metadata
PROJECT_TITLE    := ProtonVPN
PROJECT_DESC     := ProtonVPN Linux Client
PROJECT_URL      := https://ghcr.io/tprasadtp/protonvpn
PROJECT_SOURCE   := https://github.com/tprasadtp/protonvpn-docker
PROJECT_LICENSE  := GPLv3

# Upstream Metadata
UPSTREAM_VERSION := 2.2.6
UPSTREAM_URL     := https://github.com/ProtonVPN/linux-cli-community


# Include makefiles
include $(REPO_ROOT)/makefiles/help.mk
include $(REPO_ROOT)/makefiles/docker.mk

# Inject Version into image
DOCKER_EXTRA_ARGS := --build-arg VERSION=$(VERSION_ID)

.PHONY: shellcheck
shellcheck: ## Runs shellcheck
	@bash $(REPO_ROOT)/scripts/shellcheck.sh \
	$(shell find $(REPO_ROOT)/root/etc/ -type f -executable) \
	$(REPO_ROOT)/root/usr/share/shlib/logger.sh

# go releaser
.PHONY: snapshot
snapshot: ## Build snapshot
	goreleaser release --rm-dist --snapshot

.PHONY: release
release: ## Build release
	goreleaser release --rm-dist --release-notes $(REPO_ROOT)/RELEASE_NOTES.md --skip-publish

.PHONY: release-prod
release-prod: ## Build and release to production/QA
	goreleaser release --rm-dist --release-notes $(REPO_ROOT)/RELEASE_NOTES.md

.PHONY: clean
clean: ## clean
	rm -rf build/
	rm -rf dist/

.PHONY: changelog
changelog: ## Generate changelog
	$(REPO_ROOT)/scripts/changelog.sh \
		--oldest-tag 4.0.0 \
		--output $(REPO_ROOT)/docs/changelog.md \
		changelog

.PHONY: release-notes
release-notes: ## Generate release-notes
	$(REPO_ROOT)/scripts/changelog.sh \
		--output $(REPO_ROOT)/RELEASE_NOTES.md \
		release-notes

.PHONY: docs-server
docs-server: ## Server documentation
	cd docs && python3 -m http.server


.PHONY: update-scripts
update-scripts: ## Update schellscripts and libs
	curl -sSfL -o scripts/shellcheck.sh https://raw.githubusercontent.com/tprasadtp/dotfiles/master/scripts/shellcheck.sh
	curl -sSfL -o root/usr/share/shlib/logger.sh https://raw.githubusercontent.com/tprasadtp/dotfiles/master/libs/logger/logger.sh

# Enforce BUILDKIT
ifneq ($(DOCKER_BUILDKIT),1)
# DO NOT INDENT!
$(error ✖ DOCKER_BUILDKIT!=1. Docker Buildkit cannot be disabled on this repo!)
endif
