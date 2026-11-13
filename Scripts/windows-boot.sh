#!/bin/bash
# Makes Windows show up in the systemd-boot menu when it is installed on another disk
# (does nothing with other boot loaders).
# systemd-boot only finds Windows on its own EFI partition (/boot), but Windows keeps its boot
# files on the EFI partition of its own disk. This copies them (EFI/Microsoft) to /boot, where
# systemd-boot lists them as "Windows Boot Manager".
# Run it again after a large Windows update (feature update) to refresh the copy.

set -euo pipefail
[ "$EUID" -eq 0 ] || exec sudo "$0" "$@"

# Only for systemd-boot: GRUB finds Windows with os-prober, rEFInd scans every disk on its own
if ! bootctl is-installed >/dev/null 2>&1; then
    echo "systemd-boot is not installed: nothing to do (GRUB: enable os-prober and run grub-mkconfig)"
    exit 0
fi

esp=$(bootctl --print-esp-path)
esp_dev=$(findmnt -nro SOURCE --target "$esp")
mnt=$(mktemp -d)
trap 'mountpoint -q "$mnt" && umount "$mnt"; rmdir "$mnt"' EXIT

# Every EFI partition except the one systemd-boot uses
for part in $(lsblk -nrpo PATH,PARTTYPE | awk '$2 == "c12a7328-f81f-11d2-ba4b-00a0c93ec93b" { print $1 }'); do
    [ "$part" = "$esp_dev" ] && continue
    mount -o ro "$part" "$mnt" || continue
    if [ -f "$mnt/EFI/Microsoft/Boot/bootmgfw.efi" ]; then
        rm -rf "$esp/EFI/Microsoft"
        mkdir -p "$esp/EFI"
        cp -r "$mnt/EFI/Microsoft" "$esp/EFI/"
        umount "$mnt"
        echo "Copied the Windows boot files from $part to $esp/EFI/Microsoft"
        bootctl list --no-pager | grep -A3 -i windows || true
        exit 0
    fi
    umount "$mnt"
done

echo "No Windows boot files found on another EFI partition"
exit 1
