#!/usr/bin/make -f
# -*- makefile -*-
#
# See http://www.gnu.org/s/hello/manual/make/Phony-Targets.html

DEBMIRROR= http://debian.hi-media-techno.com/mirrors/debian
PKG_URL  = svn://anonscm.debian.org/pkg-postgresql/trunk
UPSTREAM = debian-8.4 debian-9.0 debian-9.1
VERSIONS = debian-8.2 debian-8.3 debian-8.4 debian-9.0 debian-9.1

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

sid: fstab
	# this runs on the 'host' system to prepare the chroot, you need sudo here
	test -d $(OUT)/usr || \
          (mkdir -p $(OUT) \
           && sudo debootstrap $@ $(OUT) $(DEBMIRROR) \
           && echo 'deb-src $(DEBMIRROR) sid main'  $(OUT)/etc/apt/sources.list)

	sudo mount proc $(OUT)/proc -t proc
	sudo mount sysfs $(OUT)/sys -t sysfs
	sudo cp /etc/hosts $(OUT)/etc/hosts

	sudo rsync -avC --exclude=debian/common ../../apt.postgresql.org $(OUT)/root
	LANG=C sudo chroot $(OUT) /root/apt.postgresql.org/debian/install-postgresql.sh

	sudo umount $(OUT)/sys
	sudo umount $(OUT)/proc

# sid:
# 	sudo pbuilder --create $@ --distribution $@ --basetgz base-$@.tgz --mirror http://ftp.fr.debian.org/debian --extrapackages build-essential lsb-release
# 	cp /var/cache/pbuilder/base.tgz pbuilder/sid.tgz 

# 	# we want to know the PATH
# 	mkdir -p /tmp/apt.postgresql.org
# 	cd .. && rsync -aC --exclude=build --exclude=debian/pbuilder ./ /tmp/apt.postgresql.org/

# 	sudo pbuilder --basetgz pbuilder/$@.tgz --bindmounts /tmp/apt.postgresql.org --execute install-postgresql.sh --save-after-exec
# 	sudo pbuilder --login --basetgz base-$@.tgz --bindmounts /tmp/apt.postgresql.org

