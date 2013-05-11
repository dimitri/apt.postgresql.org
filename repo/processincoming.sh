#!/bin/sh

QUEUE="${1:-incoming}"
[ "$QUEUE" = "incoming" ] || exit 0

[ "$USER" = "aptuser" ] || SUDO="sudo -u aptuser"

export REPREPRO_BASE_DIR="/srv/apt/repo"

set -ex

$SUDO /usr/bin/reprepro -b "REPREPRO_BASE_DIR" --morguedir "$REPREPRO_BASE_DIR/morgue" --verbose processincoming pgdg
