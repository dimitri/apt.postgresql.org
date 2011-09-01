#! /bin/bash
#
# Fetch sources for given PostgreSQL version, at given mirror
#

dirname=$1  # postgresql-X.Y
versions=$2 # filename where we have latest major minor table
mirror=$3   # where to fetch PostgreSQL sources from

source apt-fun.sh
version=`get-full-pg-version $1`

if [ -f postgresql-${version}.tar.bz2 ]; then
    echo checking PostgreSQL ${version}

    rm -f postgresql-${version}.tar.bz2.md5
    wget -nv ${mirror}/v${version}/postgresql-${version}.tar.bz2.md5

    md5sum -c postgresql-${version}.tar.bz2.md5
    if [ $? -ne 0 ]; then
	echo md5 failure, fetching a new copy
	rm -f postgresql-${version}.tar.bz2
	wget -nv ${mirror}/v${version}/postgresql-${version}.tar.bz2
    fi
else
    echo fetching PostgreSQL ${version}

    wget -nv ${mirror}/v${version}/postgresql-${version}.tar.bz2.md5
    wget -nv ${mirror}/v${version}/postgresql-${version}.tar.bz2

    md5sum -c postgresql-${version}.tar.bz2.md5
fi
