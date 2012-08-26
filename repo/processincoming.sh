#!/bin/sh

[ "$USER" = "aptuser" ] || SUDO="sudo -u aptuser"

set -x

$SUDO /usr/bin/reprepro -b /srv/apt/repo processincoming pgdg
