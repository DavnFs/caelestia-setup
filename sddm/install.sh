#!/usr/bin/env bash
# Puts the lock-screen-style login into the Caelestia SDDM theme (keeps a backup), then syncs
# your current wallpaper and colours into it. Run with sudo.
set -euo pipefail
T=/usr/share/sddm/themes/caelestia
[ -f "$T/Main.qml.orig" ] || cp "$T/Main.qml" "$T/Main.qml.orig"
install -m 0644 "$(dirname "$(readlink -f "$0")")/Main.qml" "$T/Main.qml"

# Install pacman hook to automatically re-apply customization across paru/pacman updates
mkdir -p /etc/pacman.d/hooks
cat << 'HOOK' > /etc/pacman.d/hooks/caelestia-sddm.hook
[Trigger]
Operation = Install
Operation = Upgrade
Type = Package
Target = caelestia-sddm-minimalistv2-git

[Action]
Description = Re-applying Material You SDDM theme customizations...
When = PostTransaction
Exec = /usr/bin/bash /home/davin/caelestia-setup/sddm/install.sh
HOOK

# sync.sh finds the user through SUDO_USER; pkexec only sets PKEXEC_UID
[ -n "${SUDO_USER:-}" ] || export SUDO_USER="$(id -nu "${PKEXEC_UID:?run with sudo or pkexec}")"
"$T/scripts/sync.sh"
echo "Done. Installed Material You 3 SDDM login screen and automated pacman hook."
