#!/bin/bash
# Starts awww-daemon and sets the wallpaper.
# awww remembers the last wallpaper; the default one is only set the first time.
# The desktop colors come from the wallpaper (matugen); they are generated here if missing.

DEFAULT_WALLPAPER="$HOME/Pictures/Wallpapers/Lucy-rain.png"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/awww"

pgrep -x awww-daemon >/dev/null || awww-daemon &

# Wait for the daemon to respond
for _ in $(seq 50); do
    awww query &>/dev/null && break
    sleep 0.1
done

# awww restore returns 0 even when there is no cache, so check manually
if ! find "$CACHE_DIR" -type f 2>/dev/null | grep -q . && [ -f "$DEFAULT_WALLPAPER" ]; then
    awww img "$DEFAULT_WALLPAPER"
else
    awww restore
fi

# Colors from the wallpaper (set-wallpaper.sh, matugen): only when they are missing (first start)
if [ ! -f "$HOME/.config/waybar/colors/colors.css" ]; then
    ~/.config/hypr/scripts/set-wallpaper.sh --colors
fi
