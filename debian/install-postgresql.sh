#! /bin/bash
#
# script which is run in the chroot we prepare from the main Makefile
# The apt.postgresql.org project is copied into /root
#
#	sudo rsync -avC --delete ../../apt.postgresql.org $(OUT)/root
#	sudo chroot $(OUT) /root/apt.postgresql.org/debian/install-postgresql.sh
#
# Prepares a bare pbuilder for PostgreSQL extensions building:
#  - installs postgresql-common
#  - divert supported-versions
#  - build all current PostgreSQL releases
#

set -x

# install build-essentials to bootstrap (have make installed)
apt-get install -y --force-yes build-essential
apt-get autoclean

cd /root/apt.postgresql.org/

make build-depends
make setup
make postgresql-9.1
dpkg -i debian/build/libpq5_9.1*deb \
        debian/build/postgresql-server-dev-9.1*deb \
        debian/build/postgresql-server-dev-all*deb
make postgresql-8.2
make postgresql-8.3
#make postgresql-8.4
#make postgresql-9.0
