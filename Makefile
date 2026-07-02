# Top-level Heirloom Darwin build + ALM driver.
#
# Drives phase1..phase5 across the 5 per-package repos. Companion
# repos live at $(SIBLINGS)/heirloom-<pkg>-darwin/ by default.
#
# `make help` lists all targets.

SHELL     = /bin/sh
STAGE     =
ROOT      = $(STAGE)
PREFIX   ?= /opt/heirloom
NPROC    != sysctl -n hw.ncpu 2>/dev/null || echo 4
SIBLINGS ?= $(shell dirname $(shell pwd))

MAKEARGS = ROOT=$(ROOT) -j$(NPROC)

PKGS = sh devtools toolchest doctools pkgtools

.DEFAULT_GOAL := help

.PHONY: help
help:
	@printf '\033[1mHeirloom Darwin port — top-level driver\033[0m\n\n'
	@printf 'Prefix:   %s\n' '$(PREFIX)'
	@printf 'Root:     %s (empty = direct install, else DESTDIR-style)\n' '$(ROOT)'
	@printf 'Siblings: %s (where per-package repos live)\n' '$(SIBLINGS)'
	@printf '\n\033[1mLifecycle$$\033[0m\n'
	@printf '  %-16s %s\n' 'lifecycle'   'bootstrap + configure + world + verify'
	@printf '  %-16s %s\n' 'bootstrap'   'install all brew prereqs (build + QA)'
	@printf '  %-16s %s\n' 'configure'   'validate environment for all 5 packages'
	@printf '  %-16s %s\n' 'world'       'build + install all 5 packages'
	@printf '  %-16s %s\n' 'verify'      'run verify.sh across all 5 packages'
	@printf '  %-16s %s\n' 'uninstall'   'uninstall all 5 packages'
	@printf '  %-16s %s\n' 'status'      'report installation state'
	@printf '\n\033[1mPer-phase (individual)\033[0m\n'
	@printf '  %-16s %s\n' 'phase1..5'   'build+install: sh, devtools, toolchest, doctools, pkgtools'
	@printf '  %-16s %s\n' 'phase<N>-only'   'build phase N without install'
	@printf '\n\033[1mQA + snapshot$$\033[0m\n'
	@printf '  %-16s %s\n' 'test'        'pre-commit fast + push tiers'
	@printf '  %-16s %s\n' 'test-manual' 'pre-commit manual tier (release gate)'
	@printf '  %-16s %s\n' 'snapshot'    'git-tag current state'
	@printf '  %-16s %s\n' 'clean'       'clean each package'
	@printf '\n\033[1mEnv overrides$$\033[0m\n'
	@printf '  PREFIX=/some/where     install prefix (default $(PREFIX))\n'
	@printf '  ROOT=/some/where       DESTDIR (default empty)\n'
	@printf '  SIBLINGS=/some/where   where per-package repos live\n'

# ---- top-level lifecycle ----

.PHONY: lifecycle
lifecycle: bootstrap configure world verify

.PHONY: bootstrap
bootstrap:
	@sh scripts/bootstrap.sh

.PHONY: configure
configure:
	@sh scripts/configure.sh
	@for p in $(PKGS); do \
		if [ -d $(SIBLINGS)/heirloom-$$p-darwin ]; then \
			printf '  configure %s ...\n' $$p ; \
			$(MAKE) -C $(SIBLINGS)/heirloom-$$p-darwin configure ; \
		fi ; \
	done

.PHONY: world
world: phase1 phase2 phase3 phase4 phase5

.PHONY: verify
verify:
	@sh scripts/verify.sh '$(PREFIX)'

.PHONY: uninstall
uninstall:
	@for p in $(PKGS); do \
		if [ -d $(SIBLINGS)/heirloom-$$p-darwin ]; then \
			printf '  uninstall %s ...\n' $$p ; \
			$(MAKE) -C $(SIBLINGS)/heirloom-$$p-darwin uninstall ; \
		fi ; \
	done

.PHONY: status
status:
	@for p in $(PKGS); do \
		printf '\n\033[1m%s\033[0m\n' $$p ; \
		if [ -d $(SIBLINGS)/heirloom-$$p-darwin ]; then \
			$(MAKE) -C $(SIBLINGS)/heirloom-$$p-darwin status ; \
		else \
			printf '  (companion repo not cloned at %s)\n' $(SIBLINGS)/heirloom-$$p-darwin ; \
		fi ; \
	done

# ---- per-phase ----

.PHONY: phase1 phase2 phase3 phase4 phase5
phase1:
	@if [ -d $(SIBLINGS)/heirloom-sh-darwin ]; then \
		$(MAKE) -C $(SIBLINGS)/heirloom-sh-darwin build install ; \
	else \
		printf 'error: clone https://github.com/moonman81/heirloom-sh-darwin next to this repo\n' >&2 ; exit 1 ; \
	fi

phase2:
	@if [ -d $(SIBLINGS)/heirloom-devtools-darwin ]; then \
		$(MAKE) -C $(SIBLINGS)/heirloom-devtools-darwin build install ; \
	else \
		printf 'error: clone https://github.com/moonman81/heirloom-devtools-darwin next to this repo\n' >&2 ; exit 1 ; \
	fi

phase3:
	@if [ -d $(SIBLINGS)/heirloom-toolchest-darwin ]; then \
		$(MAKE) -C $(SIBLINGS)/heirloom-toolchest-darwin build install ; \
	else \
		printf 'error: clone https://github.com/moonman81/heirloom-toolchest-darwin next to this repo\n' >&2 ; exit 1 ; \
	fi

phase4:
	@if [ -d $(SIBLINGS)/heirloom-doctools-darwin ]; then \
		$(MAKE) -C $(SIBLINGS)/heirloom-doctools-darwin build install ; \
	else \
		printf 'error: clone https://github.com/moonman81/heirloom-doctools-darwin next to this repo\n' >&2 ; exit 1 ; \
	fi

phase5:
	@if [ -d $(SIBLINGS)/heirloom-pkgtools-darwin ]; then \
		$(MAKE) -C $(SIBLINGS)/heirloom-pkgtools-darwin build install ; \
	else \
		printf 'error: clone https://github.com/moonman81/heirloom-pkgtools-darwin next to this repo\n' >&2 ; exit 1 ; \
	fi

# ---- QA passthrough ----

.PHONY: test test-manual
test:
	@pre-commit run --all-files --hook-stage pre-commit
	@pre-commit run --all-files --hook-stage pre-push

test-manual:
	@pre-commit run --all-files --hook-stage manual

.PHONY: snapshot
snapshot:
	@sh scripts/snapshot.sh

.PHONY: clone-companions
clone-companions:
	@for p in $(PKGS); do \
		if [ ! -d $(SIBLINGS)/heirloom-$$p-darwin ]; then \
			printf 'cloning heirloom-%s-darwin...\n' $$p ; \
			git -C $(SIBLINGS) clone https://github.com/moonman81/heirloom-$$p-darwin ; \
		fi ; \
	done

# ---- clean ----

.PHONY: clean
clean:
	-@for p in $(PKGS); do \
		if [ -d $(SIBLINGS)/heirloom-$$p-darwin ]; then \
			$(MAKE) -C $(SIBLINGS)/heirloom-$$p-darwin clean ; \
		fi ; \
	done
