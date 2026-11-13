#!/bin/bash
# Sets the wallpaper and recolors the desktop from it with matugen (~/.config/matugen/config.toml):
# waybar, swaync, wlogout, rofi, window borders, hyprlock and kitty.
#   set-wallpaper.sh            pick one from ~/Pictures/Wallpapers in rofi (mainMod + W)
#   set-wallpaper.sh <image>    set that image
#   set-wallpaper.sh --colors   only regenerate the colors from the current wallpaper

WALLPAPERS="$HOME/Pictures/Wallpapers"
theme="$HOME/.config/rofi/launchers/type-2/style-1.rasi"

# vibrant + the most saturated color of the image: the default (tonal-spot, most dominant color)
# gives muted pastels that look the same on most wallpapers
colors() {
    matugen image "$1" --type scheme-vibrant --prefer saturation --quiet
}

current() {
    awww query 2>/dev/null | sed -n 's/.*currently displaying: image: //p' | head -n 1
}

case "${1:-}" in
    --colors)
        image=$(current)
        [ -f "$image" ] && colors "$image"
        exit ;;
    "")
        if pgrep -x rofi >/dev/null; then
            pkill -x rofi
            exit 0
        fi
        # Grid of thumbnails: rofi shows each image as the icon of its entry
        name=$(find -L "$WALLPAPERS" -maxdepth 1 -type f \
                   \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.gif' \) \
                   -printf '%f\n' | sort | while read -r f; do
                   printf '%s\0icon\x1f%s\n' "$f" "$WALLPAPERS/$f"
               done | rofi -dmenu -i -p "󰸉" -show-icons \
                   -theme "$theme" \
                   -theme-str 'window { width: 900px; }' \
                   -theme-str 'listview { columns: 3; lines: 2; flow: horizontal; }' \
                   -theme-str 'element { orientation: vertical; }' \
                   -theme-str 'element-icon { size: 160px; }' \
                   -theme-str 'element-text { horizontal-align: 0.5; }' \
                   -theme-str 'entry { placeholder: "Search wallpapers..."; }') || exit 0
        image="$WALLPAPERS/$name" ;;
    *)
        image="$1" ;;
esac

[ -f "$image" ] || { notify-send -a Wallpaper "Wallpaper" "Not found: $image"; exit 1; }

awww img "$image" --transition-type grow --transition-duration 1 --transition-fps 60
colors "$image"
