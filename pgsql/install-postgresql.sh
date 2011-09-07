#! /bin/bash
#
# Install just build postgresql packages, those for building extensions
#

dirname=$1   # postgresql-X.Y
versions=$2  # filename where we have latest major minor table
build_dir=$3 # where to run the build

source apt-fun.sh
major=`get-major-pg-version $1`
version=`get-full-pg-version $1`

dpkg -i ${build_dir}/postgresql-client-${major}*.deb \
        ${build_dir}/postgresql-server-dev-${major}*.deb \
        ${build_dir}libpq*deb
