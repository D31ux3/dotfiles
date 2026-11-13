#!/bin/bash

echo "
    ____                      ___              __       __    __
   /  _/  __  __________     /   |  __________/ /_     / /_  / /__      __
   / /   / / / / ___/ _ \   / /| | / ___/ ___/ __ \   / __ \/ __/ | /| / /
 _/ /   / /_/ (__  )  __/  / ___ |/ /  / /__/ / / /  / /_/ / /_ | |/ |/ /
/___/   \__,_/____/\___/  /_/  |_/_/   \___/_/ /_/  /_.___/\__/ |__/|__/

"

# Directory containing this script, so it works from anywhere
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Enable multilib (needed for steam)
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    sudo sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
fi

# Update system
sudo pacman -Syu --noconfirm

# Install YAY (AUR helper)
if ! command -v yay &> /dev/null; then
    git clone https://aur.archlinux.org/yay.git /tmp/yay
    (cd /tmp/yay && makepkg -si --noconfirm)
    rm -rf /tmp/yay
fi

# GPU drivers (see gpu-drivers.sh)
"$DOTFILES/Scripts/gpu-drivers.sh"

# Packages that could not be installed, listed at the end of the script
failed=()

# install_list <file> <command...>
# Installs every package of the list in a single transaction (one dependency resolution,
# parallel downloads, each pacman hook runs once). A transaction is all or nothing, so if it
# fails (a renamed package, a conflict...) it retries one by one: the rest still gets installed
# and the failing ones are collected in $failed. Empty lines and # comments are ignored.
install_list() {
    local file="$1"; shift
    local pkgs
    mapfile -t pkgs < <(sed 's/#.*//' "$file" | tr -s ' \t' '\n' | grep -v '^$')
    [ ${#pkgs[@]} -eq 0 ] && return

    "$@" -S --needed --noconfirm "${pkgs[@]}" && return

    echo "Installing $(basename "$file") at once failed, retrying package by package"
    for pkg in "${pkgs[@]}"; do
        "$@" -S --needed --noconfirm "$pkg" || failed+=("$pkg")
    done
}

# Install official packages
install_list "$DOTFILES/pkglist.txt" sudo pacman

# xpadneo-dkms (AUR) builds its module for every installed kernel, which needs its headers
for k in $(pacman -Qq linux linux-lts linux-zen linux-hardened 2>/dev/null); do
    sudo pacman -S --needed --noconfirm "$k-headers" || failed+=("$k-headers")
done

# Install AUR packages
install_list "$DOTFILES/aurlist.txt" yay

# Install OHMYZSH (zsh is installed with official packages)
if [ ! -d ~/.oh-my-zsh ]; then
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
fi

# Link configuration files and wallpapers (symlinks, see link.sh)
"$DOTFILES/Scripts/link.sh"

# VS Code extensions (theme, icons, formatter... used by the versioned settings.json).
# Update the list with: code --list-extensions > vscode-extensions.txt
while read -r ext || [ -n "$ext" ]; do
    [ -z "$ext" ] && continue
    code --install-extension "$ext" || echo "Failed to install extension: $ext"
done < "$DOTFILES/vscode-extensions.txt"

# Dolphin only applies the KDE color scheme on startup when one is set explicitly;
# with "Default" it mixes the qt6ct palette and kdeglobals (light background, light text)
kwriteconfig6 --file dolphinrc --group UiSettings --key ColorScheme BreezeDark

# Open images with satty (writes ~/.config/mimeapps.list)
xdg-mime default satty.desktop image/png image/jpeg image/webp image/bmp

# Git settings written into ~/.gitconfig (not versioned: it holds the user's identity)
# Large files (textures, models, audio) through LFS, in the repos that enable it in .gitattributes
git lfs install
# Diffs with syntax highlighting and word-level changes; n/N jumps between files
git config --global core.pager delta
git config --global interactive.diffFilter "delta --color-only"
git config --global delta.navigate true
git config --global merge.conflictStyle zdiff3

# System files: Configs/etc/<path> is copied to /etc/<path> (root-owned copies, not symlinks:
# they are read before login and must not depend on the home directory). Run again after editing them.
# zram-generator.conf: compressed swap in RAM, active after reboot
# docker/daemon.json: Docker does not drop other forwarded traffic (the VMs' network)
(cd "$DOTFILES/Configs/etc" && find . -type f) | while read -r f; do
    sudo install -Dm644 "$DOTFILES/Configs/etc/$f" "/etc/${f#./}"
done

# Enable GUI login (SDDM). Only one display manager can be enabled,
# so disable the one a previous install left (gdm, lightdm...)
dm=$(readlink /etc/systemd/system/display-manager.service)
if [ -n "$dm" ] && [ "$(basename "$dm")" != "sddm.service" ]; then
    sudo systemctl disable "$(basename "$dm")"
fi
sudo systemctl enable sddm
# SDDM has no default-session setting, it preselects the last session used (state.conf).
# Point it to Hyprland when there is none yet or it no longer exists (e.g. GNOME was removed)
last_session=$(sudo sed -n 's/^Session=//p' /var/lib/sddm/state.conf 2>/dev/null)
if [ ! -f "$last_session" ]; then
    printf '[Last]\nSession=/usr/share/wayland-sessions/hyprland.desktop\n' | sudo tee /var/lib/sddm/state.conf > /dev/null
fi
# Enable NetworkManager
sudo systemctl enable NetworkManager
# Wi-Fi goes through NetworkManager + wpa_supplicant (started by NM, not enabled on its own);
# a leftover iwd service would fight NM for the Wi-Fi card
if systemctl is-enabled -q iwd 2>/dev/null; then
    sudo systemctl disable --now iwd
fi
# Enable bluetooth
sudo systemctl enable bluetooth
# Power profiles (power-saver / balanced / performance), switched from waybar
sudo systemctl enable power-profiles-daemon
# Enable fstrim.timer that automatically performs TRIM operations
# to maintain performance and extend lifespan.
sudo systemctl enable fstrim.timer
# Clean the pacman package cache weekly, keeping the last 3 versions of each package
sudo systemctl enable paccache.timer
# Docker starts on the first docker command (socket), not at boot.
# The docker group allows using it without sudo (applies after logging in again)
sudo systemctl enable docker.socket
sudo usermod -aG docker "$USER"
# Virtual machines (virt-manager + QEMU/KVM). libvirtd starts on first use (socket).
# The libvirt group lets virt-manager manage system VMs (qemu:///system) without a password
sudo systemctl enable --now libvirtd.socket
sudo usermod -aG libvirt "$USER"
# NAT network for the VMs: start it now and on every boot (connecting starts libvirtd)
sudo virsh net-autostart default >/dev/null
sudo virsh net-start default >/dev/null 2>&1 || true   # fails if it is already running
# gamemode (gamemoderun) changes the CPU governor and process priority only for the gamemode group
sudo usermod -aG gamemode "$USER"

if [ ${#failed[@]} -gt 0 ]; then
    echo
    echo "These packages could not be installed (see the errors above):"
    printf '  %s\n' "${failed[@]}"
    echo
fi

echo "reboot your system"
