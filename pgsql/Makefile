#!/usr/bin/make -f
# -*- makefile -*-
#
# See http://www.gnu.org/s/hello/manual/make/Phony-Targets.html

SOURCE = http://www.postgresql.org/ftp/source/
MIRROR = http://ftp4.fr.postgresql.org/pub/mirrors/postgresql/source/
VERSIONS = postgresql-8.3 postgresql-8.4 postgresql-9.0 postgresql-9.1

PGMP_URL = https://github.com/dvarrazzo/pgmp.git
PGMP_DEB = $(abspath ../debian/pkg-postgresql/trunk/postgresql-pgmp/debian)

.PHONY: setup $(VERSIONS)

build: $(VERSIONS)

$(VERSIONS): minor-versions.txt
	bash fetch-sources.sh $@ $< $(MIRROR)
	bash build-sources.sh $@ $< $(OUT)

minor-versions.txt:
	curl -s $(SOURCE) |awk -f minor-versions.awk > $@

clean:
	rm -f minor-versions.txt

pgmp:
	cd $(OUT) && (test -d $@ && (cd $@ && git pull) || git clone $(PGMP_URL) $@)
	chmod a+x $(OUT)/$@/tools/*py
	cd $(OUT) && tar czf postgresql-pgmp_`head -1 $(PGMP_DEB)/changelog |awk -F '[()-]' '{print $$3}'`.orig.tar.gz --exclude-vcs $@
	rsync -Ca $(PGMP_DEB) $(OUT)/$@
	sudo apt-get install libgmp3-dev
	perl -pi -e "s/libgmp-dev/libgmp3-dev/" $(OUT)/$@/debian/control
	> $(OUT)/$@/debian/patches/series
	cd $(OUT)/$@ && debuild -us -uc -sa
