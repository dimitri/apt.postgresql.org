#!/usr/bin/make -f
# -*- makefile -*-
#
# scripts to build postgresql debian packages
# and extensions too

# where to build
OUT  = /var/cache/pbuilder/build/pg
REL  = $(shell lsb_release -sc)
ARCH = $(shell dpkg --print-architecture)

VERSIONS = 8.2 8.3 8.4 9.0 9.1
MAJORS   = $(addprefix postgresql-, $(VERSIONS))
DISTROS  = sid #wheezy squeeze lenny

all: postgresql extensions

postgresql: postgresql-common postgresql-8.4 postgresql-9.0 postgresql-9.1

build-depends:
	# this typically runs as root inside a chroot
	apt-get update
	apt-get install -y  bzr curl bzip2 tar gawk lsb-release git-core \
                            debootstrap rebuildd
	apt-get -f install
	apt-get autoclean
	for v in $(VERSIONS); do \
		apt-get build-dep -y postgresql-$$v; \
	done
	apt-get autoclean

$(DISTROS):
	mkdir -p $(OUT)/$@/$(ARCH)
	make OUT=$(abspath $(OUT))/$@/$(ARCH) -C debian $@

setup:
	# this typically runs as root inside a chroot	
	mkdir -p build
	make -C debian $@

postgresql-common:
	make -C debian $@

$(MAJORS):
	# this typically runs as root inside a chroot
	make OUT=$(abspath build) -C pgsql $@

%:
	# this typically runs as root inside a chroot
	make OUT=$(abspath build) -C pgsql $@
