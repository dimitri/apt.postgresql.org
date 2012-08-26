#!/bin/sh

[ "$USER" = "aptuser" ] || SUDO="sudo -u aptuser"

set -ex

$SUDO /usr/bin/reprepro -b /srv/apt/repo --verbose processincoming pgdg
