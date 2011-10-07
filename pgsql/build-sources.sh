#! /bin/bash
#
# Prepare sources for given PostgreSQL version
#
set -x

dirname=$1   # postgresql-X.Y
versions=$2  # filename where we have latest major minor table
build_dir=$3 # where to run the build

source apt-fun.sh
major=`get-major-pg-version $1`
version=`get-full-pg-version $1`

rm -rf ${build_dir}/postgresql-${version}
rm -f ${build_dir}/postgresql-${major}_${version}.orig.tar.bz2

tar xjf postgresql-${version}.tar.bz2 -C ${build_dir}
cp -a ../debian/debian-${major}/debian ${build_dir}/postgresql-${version}
ln -s `pwd`/postgresql-${version}.tar.bz2 ${build_dir}/postgresql-${major}_${version}.orig.tar.bz2

cd ${build_dir}/postgresql-${version} && \
EMAIL=dimitri@2ndQuadrant.fr dch -v ${version}-1+pgdg "see Releases Notes"

cd ${build_dir}/postgresql-${version} && debuild -us -uc -sa

