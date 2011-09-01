#!/usr/bin/make -f
# -*- makefile -*-
#
# See http://www.gnu.org/s/hello/manual/make/Phony-Targets.html

SOURCE = http://www.postgresql.org/ftp/source/
MIRROR = http://ftp4.fr.postgresql.org/pub/mirrors/postgresql/source/
VERSIONS = postgresql-8.3 postgresql-8.4 postgresql-9.0 postgresql-9.1

.PHONY: setup $(VERSIONS)

build: $(VERSIONS)

$(VERSIONS): minor-versions.txt
	bash fetch-sources.sh $@ $< $(MIRROR)
	bash build-sources.sh $@ $< $(OUT)

minor-versions.txt:
	wget -q -O- $(SOURCE)  |gunzip |awk -f minor-versions.awk > $@

clean:
	rm -f minor-versions.txt
