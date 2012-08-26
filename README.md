# apt.postgresql.org

Policy draft: http://wiki.debian.org/pkg-postgresql/Workflow

The main idea of this project is to provide PostgreSQL and its Extensions
packages for all supported PostgreSQL versions and debian version. That
means things like PostgreSQL 9.1 for `squeeze`, with all known debian
extensions, and for `sid` and `wheezy` too. And same for `8.3` and `8.4` and
`9.0` and `9.1` and `9.2`. Targeting `i386` and `amd64`.

Progress is being made. For real.

## Build System

The build system is currently based on jenkins and some scripting. `Jenkins`
is only about lauching the build jobs, the real work is done in the scripts.
The scripts are using `cowbuilder` and `dpkg-buildpackage`.

## Sources

Either `bzr` or `git` or `svn`, or `apt-get source`.

## WIP

Please see the *hackathon* document for latest progress information.

## Hosting

We're working on it and will keep you updated, PostgreSQL infrastructure
will do the hosting for us.

## Deprecation

Most scripts and tools in this repository are going to be soon deprecated
and we alredy stopped depending on them. It was research, allowed us to know
where to go, but are not usable as they are.
