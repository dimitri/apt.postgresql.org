#!/usr/bin/make -f
# -*- makefile -*-
#
# See http://www.gnu.org/s/hello/manual/make/Phony-Targets.html

VERSIONS = debian-8.3 debian-8.4 debian-9.0 debian-9.1

.PHONY: setup $(VERSIONS)

setup: $(VERSIONS) postgresql-common

$(VERSIONS):
	test -d $@ && (cd $@ && bzr pull) || bzr clone lp:~pitti/postgresql/$@

postgresql-common:
	test -d common && (cd common && bzr pull) || bzr clone lp:~pitti/postgresql/common
	cd common && debuild -us -uc -sa
	for p in `(cd common && debc)| awk '/^postgresql/ && (/common/ || /server/)'`; do \
		sudo dpkg -i $$p; \
	done
