#!/bin/sh

QUEUE="${1:-incoming}"
[ "$QUEUE" = "incoming" ] || exit 0

[ "$USER" = "aptuser" ] || SUDO="sudo -u aptuser"

set -ex

$SUDO /usr/bin/reprepro -b /srv/apt/repo --verbose processincoming pgdg
