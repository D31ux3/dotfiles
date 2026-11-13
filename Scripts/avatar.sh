#!/bin/bash
# Sets the profile picture: ./avatar.sh [image]   (default: the first image in Assets/Pictures/pfp)
# - Login screen: SDDM cannot read the home folder (it is private), so the picture is copied to
#   /usr/share/sddm/faces/<user>.face.icon (asks for the password). SilentSDDM crops it to fit.
# - ~/.face points to it, the usual per-user avatar file; hyprlock shows it above the clock.
# Run it again after changing the picture.

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
image="${1:-$(find "$DOTFILES/Assets/Pictures/pfp" -maxdepth 1 -type f \
    \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \) 2>/dev/null | sort | head -n 1)}"

if [ -z "$image" ] || [ ! -f "$image" ]; then
    echo "No profile picture: put one in Assets/Pictures/pfp or pass its path"
    exit 1
fi
image="$(realpath "$image")"

sudo install -Dm644 "$image" "/usr/share/sddm/faces/$USER.face.icon"
ln -sfn "$image" "$HOME/.face"
echo "Profile picture set to $image"
