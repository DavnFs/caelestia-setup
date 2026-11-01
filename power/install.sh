#!/usr/bin/env bash
# Installs and starts the power-limit service. Run with sudo after installing ryzenadj.
# Undo: sudo systemctl disable --now power-profile-watts && sudo rm /usr/local/bin/power-profile-watts /etc/systemd/system/power-profile-watts.service
set -euo pipefail
command -v ryzenadj >/dev/null || { echo "Install ryzenadj first (paru -S ryzenadj-git)"; exit 1; }
here=$(dirname "$(readlink -f "$0")")
install -m 0755 "$here/power-profile-watts" /usr/local/bin/power-profile-watts
install -m 0644 "$here/power-profile-watts.service" /etc/systemd/system/power-profile-watts.service
systemctl daemon-reload
systemctl enable --now power-profile-watts
sleep 2
journalctl -u power-profile-watts -n 3 --no-pager
