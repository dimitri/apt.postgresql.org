#!/usr/bin/make -f
# -*- makefile -*-
#
# See http://www.gnu.org/s/hello/manual/make/Phony-Targets.html

DEBMIRROR= http://debian.hi-media-techno.com/mirrors/debian
OBTMIRROR= http://fr.archive.ubuntu.com/ubuntu/
PKG_URL  = svn://anonscm.debian.org/pkg-postgresql/trunk
UPSTREAM = debian-8.4 debian-9.0 debian-9.1
VERSIONS = debian-8.2 debian-8.3 debian-8.4 debian-9.0 debian-9.1
DISTROS  = lenny squeeze wheezy sid
UBUNTUS  = lucid maverick natty oneiric

# .PHONY: setup $(UPSTREAM)

setup: $(UPSTREAM) postgresql-common

$(UPSTREAM):
	test -d $@ && (cd $@ && bzr pull) || bzr clone lp:~pitti/postgresql/$@

divert-supported-versions:
	# divert supported versions so that it returns all our local PG build versions
	# this typically runs as root inside a chroot
	dpkg-divert \
	  --divert /usr/share/postgresql-common/supported-versions.distrib \
	  --rename /usr/share/postgresql-common/supported-versions
	install -m 0755 supported-versions /usr/share/postgresql-common

undivert-supported-versions:
	# this typically runs as root inside a chroot
	test -f /usr/share/postgresql-common/supported-versions.distrib
	rm /usr/share/postgresql-common/supported-versions
	dpkg-divert --rename \
	  --remove /usr/share/postgresql-common/supported-versions

postgresql-common: divert-supported-versions
	# this typically runs as root inside a chroot
	test -d common && (cd common && bzr pull) || bzr clone lp:~pitti/postgresql/common
	cd common && (echo yes | mk-build-deps -i -r)
	cd common && debuild -us -uc -sa
	for p in `(cd common && debc)| awk '/^postgresql/ && (/common/)'`; do \
		echo $$p; \
	done | xargs dpkg -i
	mkdir -p build
	(cd common && debc) | awk /^postgresql/ | xargs -I% mv % build
	mv postgresql-common_* build

fstab:
	if ! `grep -q $(OUT) /etc/fstab`; then \
		echo "proc $(OUT)/proc proc defaults,noauto 0 0" | sudo tee -a /etc/fstab;  \
		echo "sysfs $(OUT)/sys sysfs defaults,noauto 0 0" | sudo tee -a /etc/fstab; \
	fi

$(addprefix debootstrap-, $(DISTROS)):
	# this runs on the 'host' system to prepare the chroot, you need sudo here
	test -d $(OUT)/usr || \
          (mkdir -p $(OUT) \
           && sudo debootstrap $(subst debootstrap-,,$@) $(OUT) $(DEBMIRROR) \
           && echo 'deb-src $(DEBMIRROR) $(subst debootstrap-,,$@) main'  $(OUT)/etc/apt/sources.list)

$(addprefix debootstrap-, $(UBUNTUS)):
	# this runs on the 'host' system to prepare the chroot, you need sudo here
	test -d $(OUT)/usr || \
          (mkdir -p $(OUT) \
           && sudo debootstrap $(subst debootstrap-,,$@) $(OUT) $(OBTMIRROR) \
           && echo 'deb-src $(OBTMIRROR) $(subst debootstrap-,,$@) main'  $(OUT)/etc/apt/sources.list)

$(DISTROS) $(UBUNTUS): %: fstab debootstrap-%
	sudo mount proc $(OUT)/proc -t proc
	sudo mount sysfs $(OUT)/sys -t sysfs
	sudo cp /etc/hosts $(OUT)/etc/hosts

	sudo rsync -avC --exclude=debian/common --exclude=build \
                   $(abspath ../../apt.postgresql.org) $(OUT)/root
	LANG=C sudo chroot $(OUT) /root/apt.postgresql.org/debian/install-postgresql.sh

	sudo umount $(OUT)/sys
	sudo umount $(OUT)/proc
