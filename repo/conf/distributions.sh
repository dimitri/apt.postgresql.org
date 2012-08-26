#!/bin/sh

DISTRIBUTIONS="sid wheezy squeeze lenny etch"
FLAVORS="pgdg pgdg-testing pgdg-deprecated"

for DIST in $DISTRIBUTIONS ; do
	for FLAVOR in $FLAVORS ; do
		D="$DIST-$FLAVOR"
		cat <<EOF
Codename: $D
Suite: $D
Origin: apt.postgresql.org
Label: PostgreSQL for Debian/Ubuntu repository
Architectures: source amd64 i386
Components: main 8.2 8.3 8.4 9.0 9.1 9.2
SignWith: ACCC4CF8
Log: $D.log
Uploaders: uploaders
DebIndices: Packages Release . .gz .bz2
UDebIndices: Packages . .gz .bz2
DscIndices: Sources Release .gz .bz2
Tracking: all
Contents:

EOF
	done
done
