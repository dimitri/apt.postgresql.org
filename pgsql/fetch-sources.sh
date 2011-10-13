#! /bin/bash
#
# Fetch sources for given PostgreSQL version, at given mirror
#

dirname=$1  # postgresql-X.Y
versions=$2 # filename where we have latest major minor table
mirror=$3   # where to fetch PostgreSQL sources from

source apt-fun.sh
version=`get-full-pg-version $1`

`set-archive-md5sum`

if [ -f ${archive} ]; then
    echo checking PostgreSQL ${version}

    rm -f ${md5sum}
    wget -nv ${mirror}/v${version}/${md5sum}

    md5sum -c ${md5sum}
    if [ $? -ne 0 ]; then
	echo md5 failure, fetching a new copy
	rm -f ${archive}
	wget -nv ${mirror}/v${version}/${archive}
    fi
else
    echo fetching PostgreSQL ${version}

    wget -nv ${mirror}/v${version}/${md5sum}
    wget -nv ${mirror}/v${version}/${archive}

    md5sum -c ${md5sum}
fi
