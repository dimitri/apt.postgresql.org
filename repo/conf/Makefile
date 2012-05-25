VERSIONS=8.1 8.2 8.3 8.4 9.0 9.1 9.2

POSTGRES = \
	   postgresql-XY             \
	   postgresql-XY-dbg         \
	   postgresql-client-XY      \
	   postgresql-contrib-XY     \
	   postgresql-doc-XY         \
	   postgresql-plperl-XY      \
	   postgresql-plpython-XY    \
	   postgresql-pltcl-XY       \
	   postgresql-server-dev-XY  \
	   postgresql-common         \
	   postgresql-client-common  \
	   postgresql-server-dev-all \
	   postgresql                \
	   postgresql-client         \
	   postgresql-doc            \
	   postgresql-contrib        \
	   libpq5                    \
	   libpq-dev                 \
	   libecpg-compat2           \
	   libecpg-dev               \
	   libecpg5                  \
	   libpgtypes2

MODULES = \
	  ip4r			postgresql-XY-ip4r \
	  hstore-new		postgresql-XY-hstore-new \
	  orafce		postgresql-XY-orafce \
	  pgfincore		postgresql-XY-pgfincore \
	  pgmemcache		postgresql-XY-pgmemcache \
	  plr			postgresql-XY-plr \
	  postgresql-debversion	postgresql-XY-debversion \
	  postgresql-pljava	postgresql-XY-pljava-gcj \
	  postgresql-pllua	postgresql-XY-pllua \
	  postgresql-plproxy	postgresql-XY-plproxy \
	  postgresql-plruby	postgresql-XY-plruby \
	  postgresql-plsh	postgresql-XY-plsh \
	  prefix		postgresql-XY-prefix \
	  preprepare		postgresql-XY-preprepare \
	  skytools		skytools-modules-XY \
	  skytools3		python-pgq3 python-skytools3 skytools3-walmgr skytools3-ticker postgresql-XY-pgq3 \
	  slony1		slony1-bin postgresql-XY-slony1 slony1-doc \
	  slony1-2		slony1-2-bin postgresql-XY-slony1-2 slony1-2-doc \

all: postgresql-packages modules-packages

postgresql-packages: Makefile
	for pkg in $(foreach version,$(VERSIONS),$(subst XY,$(version),$(POSTGRES))) ; do echo $$pkg install ; done | sort -u > $@

modules-packages: Makefile
	for pkg in $(foreach version,$(VERSIONS),$(subst XY,$(version),$(MODULES))) ; do echo $$pkg install ; done | sort -u > $@
