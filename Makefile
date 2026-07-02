# Top-level Heirloom Darwin build driver.
#
# Usage:
#   make phase1                    build heirloom-sh
#   make phase1-install            install heirloom-sh
#   make phase2  phase2-install    build+install devtools
#   ... etc through phase5 ...
#   make all                       phases 1..5 in order (build only)
#   make world                     phases 1..5 build+install in order
#   make clean                     wipe build products from every package
#   make distclean                 wipe generated Makefiles too
#
# Set STAGE=/some/path to install via DESTDIR-style redirection.

SHELL   = /bin/sh
STAGE   =
ROOT    = $(STAGE)
NPROC  != sysctl -n hw.ncpu 2>/dev/null || echo 4

MAKEARGS = ROOT=$(ROOT) -j$(NPROC)

.PHONY: all world clean distclean \
        phase1 phase1-install \
        phase2 phase2-install \
        phase3 phase3-install \
        phase4 phase4-install \
        phase5 phase5-install \
        prefixdirs

all:     phase1 phase2 phase3 phase4 phase5
world:   phase1-install phase2-install phase3-install phase4-install phase5-install

prefixdirs:
	@mkdir -p $(ROOT)/opt/heirloom/bin/s42 \
	          $(ROOT)/opt/heirloom/bin/posix \
	          $(ROOT)/opt/heirloom/bin/posix2001 \
	          $(ROOT)/opt/heirloom/ucb \
	          $(ROOT)/opt/heirloom/ccs/bin \
	          $(ROOT)/opt/heirloom/lib \
	          $(ROOT)/opt/heirloom/share/man/5man \
	          $(ROOT)/opt/heirloom/etc/default \
	          $(ROOT)/opt/heirloom/var/adm \
	          $(ROOT)/opt/heirloom/var/log

# ---------------- phase 1: sh ----------------
phase1:
	cd sh && $(MAKE)
phase1-install: prefixdirs
	cd sh && $(MAKE) install ROOT=$(ROOT)

# ---------------- phase 2: devtools ----------------
phase2:
	cd devtools && $(MAKE) $(MAKEARGS)
phase2-install: prefixdirs
	cd devtools && $(MAKE) install $(MAKEARGS)

# ---------------- phase 3: toolchest ----------------
phase3:
	cd toolchest && $(MAKE) $(MAKEARGS)
phase3-install: prefixdirs
	cd toolchest && $(MAKE) install $(MAKEARGS)

# ---------------- phase 4: doctools ----------------
phase4:
	cd doctools && $(MAKE) $(MAKEARGS)
phase4-install: prefixdirs
	cd doctools && $(MAKE) install $(MAKEARGS)

# ---------------- phase 5: pkgtools ----------------
phase5:
	cd pkgtools && $(MAKE) $(MAKEARGS)
phase5-install: prefixdirs
	cd pkgtools && $(MAKE) install $(MAKEARGS)

# ---------------- housekeeping ----------------
clean:
	-cd sh        && $(MAKE) clean
	-cd devtools  && $(MAKE) mrproper
	-cd toolchest && $(MAKE) mrproper
	-cd doctools  && $(MAKE) mrproper
	-cd pkgtools  && $(MAKE) mrproper

distclean: clean
	find sh devtools toolchest doctools pkgtools -name Makefile -not -path '*/original*' -delete
