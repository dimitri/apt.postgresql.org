#!/usr/bin/make -f
# -*- makefile -*-
#
# See http://www.gnu.org/s/hello/manual/make/Phony-Targets.html

PKG_URL  = svn://anonscm.debian.org/pkg-postgresql/trunk
UPSTREAM = debian-8.4 debian-9.0 debian-9.1
VERSIONS = debian-8.3 debian-8.4 debian-9.0 debian-9.1

.PHONY: setup $(UPSTREAM)

setup: $(UPSTREAM) postgresql-common

$(UPSTREAM):
	test -d $@ && (cd $@ && bzr pull) || bzr clone lp:~pitti/postgresql/$@

divert-supported-versions:
	# divert supported versions so that it returns all our local PG build versions
	sudo dpkg-divert \
	  --divert /usr/share/postgresql-common/supported-versions.distrib \
	  --rename /usr/share/postgresql-common/supported-versions
	sudo install -m 0755 supported-versions /usr/share/postgresql-common

postgresql-common: divert-supported-versions
	test -d common && (cd common && bzr pull) || bzr clone lp:~pitti/postgresql/common
	cd common && debuild -us -uc -sa
	for p in `(cd common && debc)| awk '/^postgresql/ && (/common/ || /server/)'`; do \
		sudo dpkg -i $$p; \
	done
	mkdir -p build
	(cd common && debc) | awk /^postgresql/ | xargs -I% mv % build
	mv postgresql-common_* build
