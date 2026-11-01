#!/usr/bin/env bash
# Enables hibernation on this btrfs + zram system and makes closing the lid sleep, then hibernate after 1 hour.
# Run as root. Resume needs no kernel parameter: systemd >= 255 records the swap file location in an EFI
# variable at hibernate time and the initramfs "systemd" hook resumes from it.
# Undo: swapoff /swap/swapfile; remove its fstab line; rm -r /swap (btrfs subvolume delete /swap);
#       rm /etc/systemd/sleep.conf.d/hibernate-delay.conf /etc/systemd/logind.conf.d/lid-hibernate.conf
set -euo pipefail

# Swap file in its own subvolume so snapshots skip it; 20 GB covers 15 GB of RAM
if [ ! -e /swap/swapfile ]; then
    btrfs subvolume create /swap
    btrfs filesystem mkswapfile --size 20g /swap/swapfile
fi
# Lowest priority: zram keeps doing normal swapping, the file is only for hibernation
grep -q '^/swap/swapfile ' /etc/fstab || echo '/swap/swapfile none swap defaults,pri=1 0 0' >>/etc/fstab
swapon --show=NAME --noheadings | grep -qx /swap/swapfile || swapon --priority 1 /swap/swapfile

mkdir -p /etc/systemd/sleep.conf.d /etc/systemd/logind.conf.d
printf '[Sleep]\nHibernateDelaySec=1h\n' >/etc/systemd/sleep.conf.d/hibernate-delay.conf
printf '[Login]\nHandleLidSwitch=suspend-then-hibernate\n' >/etc/systemd/logind.conf.d/lid-hibernate.conf
# Reload (not restart) so the running session is untouched
systemctl reload systemd-logind

swapon --show
echo "CanHibernate: $(busctl call org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager CanHibernate)"
echo "CanSuspendThenHibernate: $(busctl call org.freedesktop.login1 /org/freedesktop/login1 org.freedesktop.login1.Manager CanSuspendThenHibernate)"
