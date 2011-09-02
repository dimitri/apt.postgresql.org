#!/usr/bin/make -f
# -*- makefile -*-
#
# See http://www.gnu.org/s/hello/manual/make/Phony-Targets.html

PKG_URL  = svn://anonscm.debian.org/pkg-postgresql/trunk
VERSIONS = debian-8.3 debian-8.4 debian-9.0 debian-9.1

.PHONY: setup $(VERSIONS) pkg-postgresql

setup: $(VERSIONS) postgresql-common

$(VERSIONS):
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
	mv postgresql-common_*.{build,changes,dsc,tar.gz} build

pkg-postgresql:
	mkdir -p $@
	cd $@ && (test -d trunk && (cd trunk && svn up) || svn checkout $(PKG_URL))
