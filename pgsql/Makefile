#!/usr/bin/make -f
# -*- makefile -*-
#
# See http://www.gnu.org/s/hello/manual/make/Phony-Targets.html

SOURCE = http://www.postgresql.org/ftp/source/
MIRROR = http://ftp4.fr.postgresql.org/pub/mirrors/postgresql/source/
VERSIONS = postgresql-8.3 postgresql-8.4 postgresql-9.0 postgresql-9.1

SKYTOOLS_DEB = $(abspath ../debian/divert/skytools/debian)

.PHONY: setup $(VERSIONS)

build: $(VERSIONS)

$(VERSIONS): minor-versions.txt
	bash fetch-sources.sh $@ $< $(MIRROR)
	bash build-sources.sh $@ $< $(OUT)

minor-versions.txt:
	curl -s $(SOURCE) |awk -f minor-versions.awk > $@

clean:
	rm -f minor-versions.txt

postgresql-pgmp:
	sudo apt-get install libgmp3-dev
	cd $(OUT) && apt-get source $@
	perl -pi -e "s/libgmp-dev/libgmp3-dev/" $(OUT)/$@-*/debian/control
	cd $(OUT)/$@-* && debuild -us -uc -sa

skytools:
	sudo apt-get build-dep $@
	cd $(OUT) && apt-get source $@
	cp -a $(SKYTOOLS_DEB)/* $(OUT)/$@-*/debian/
	cd $(OUT)/$@-* && debuild -us -uc -sa
