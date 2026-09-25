#!/bin/bash
# Arranca awww-daemon y pone el wallpaper.
# awww recuerda el último wallpaper; el de por defecto solo se pone la primera vez.

DEFAULT_WALLPAPER="$HOME/Pictures/Wallpapers/Lucy-rain.png"
CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/awww"

pgrep -x awww-daemon >/dev/null || awww-daemon &

# Esperar a que el daemon responda
for _ in $(seq 50); do
    awww query &>/dev/null && break
    sleep 0.1
done

# awww restore devuelve 0 aunque no haya caché, por eso se revisa a mano
if ! find "$CACHE_DIR" -type f 2>/dev/null | grep -q . && [ -f "$DEFAULT_WALLPAPER" ]; then
    awww img "$DEFAULT_WALLPAPER"
else
    awww restore
fi
