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

# Install official packages
while read -r pkg || [ -n "$pkg" ]; do
    [ -z "$pkg" ] && continue
    sudo pacman -S --needed --noconfirm "$pkg" || echo "Failed to install: $pkg"
done < "$DOTFILES/pkglist.txt"

# Install AUR packages
while read -r pkg || [ -n "$pkg" ]; do
    [ -z "$pkg" ] && continue
    yay -S --needed --noconfirm "$pkg" || echo "Failed to install: $pkg"
done < "$DOTFILES/aurlist.txt"

# Install OHMYZSH (zsh is installed with official packages)
if [ ! -d ~/.oh-my-zsh ]; then
    git clone --depth=1 https://github.com/ohmyzsh/ohmyzsh.git ~/.oh-my-zsh
fi

# Link configuration files and wallpapers (symlinks, see link.sh)
"$DOTFILES/Scripts/link.sh"

# Dolphin only applies the KDE color scheme on startup when one is set explicitly;
# with "Default" it mixes the qt6ct palette and kdeglobals (light background, light text)
kwriteconfig6 --file dolphinrc --group UiSettings --key ColorScheme BreezeDark

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

echo "reboot your system"
