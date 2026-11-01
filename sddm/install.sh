#!/usr/bin/env bash
# Puts the lock-screen-style login into the Caelestia SDDM theme (keeps a backup), then syncs
# your current wallpaper and colours into it. Run with sudo. Re-run after the theme package updates.
set -euo pipefail
T=/usr/share/sddm/themes/caelestia
[ -f "$T/Main.qml.orig" ] || cp "$T/Main.qml" "$T/Main.qml.orig"
install -m 0644 "$(dirname "$(readlink -f "$0")")/Main.qml" "$T/Main.qml"
# sync.sh finds the user through SUDO_USER; pkexec only sets PKEXEC_UID
[ -n "${SUDO_USER:-}" ] || export SUDO_USER="$(id -nu "${PKEXEC_UID:?run with sudo or pkexec}")"
"$T/scripts/sync.sh"
echo "Done. Undo with: sudo cp $T/Main.qml.orig $T/Main.qml"
