#!/usr/bin/make -f
# -*- makefile -*-
#
# scripts to build postgresql debian packages
# and extensions too

# where to build
OUT  = /var/cache/pbuilder/build/pg
REL  = $(shell lsb_release -sc)
ARCH = $(shell dpkg --print-architecture)

VERSIONS = 8.3 8.4 9.0 9.1
MAJORS   = $(addprefix postgresql-, $(VERSIONS))

all: postgresql extensions

postgresql: postgresql-common postgresql-8.4 postgresql-9.0 postgresql-9.1

build-depends:
	sudo apt-get install bzr curl bzip2 tar gawk lsb-release git-core
	for v in $(VERSIONS); do \
		sudo apt-get build-dep postgresql-$$v; \
	done

build-dir:
	mkdir -p $(abspath $(OUT))/$(REL)/$(ARCH)

setup:
	make -C debian $@

postgresql-common:
	make -C debian $@

$(MAJORS): setup build-dir
	make OUT=$(abspath $(OUT))/$(REL)/$(ARCH) -C pgsql $@

%: build-dir
	echo $(MAJORS)
	make OUT=$(abspath $(OUT))/$(REL)/$(ARCH) -C pgsql $@
