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

`set-archive-md5sum`

rm -rf ${build_dir}/postgresql-${version}
rm -f ${build_dir}/postgresql-${major}_${version}.orig.tar.${Z}

tar xjf ${archive} -C ${build_dir}
cp -a ../debian/debian-${major}/debian ${build_dir}/postgresql-${version}
ln -s `pwd`/${archive} ${build_dir}/postgresql-${major}_${version}.orig.tar.${Z}

cd ${build_dir}/postgresql-${version} && \
EMAIL=dimitri@2ndQuadrant.fr dch -v ${version}-1+pgdg "see Releases Notes"

cd ${build_dir}/postgresql-${version} && echo yes | mk-build-deps -i -r
apt-get-clean
cd ${build_dir}/postgresql-${version} && debuild -us -uc -sa
rm -rf ${build_dir}/postgresql-${version}

# don't override libpq-dev, we install the most recent one first
if dpkg-query -W -f'${Status}\n' libpq-dev | grep -q installed; then
    echo libpq-dev ok
    dpkg -i postgresql-server-dev-${major}*deb
else
    dpkg -i libpq-dev_${major}*deb postgresql-server-dev-${major}*deb
fi
