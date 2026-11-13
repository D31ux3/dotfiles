#!/bin/bash
# Sets the wallpaper and recolors the desktop from it with matugen (~/.config/matugen/config.toml):
# waybar, swaync, wlogout, rofi, window borders, hyprlock and kitty.
#   set-wallpaper.sh            pick one from ~/Pictures/Wallpapers (and its subfolders) in rofi (mainMod + W)
#   set-wallpaper.sh <file>     set that image or video
#   set-wallpaper.sh --colors   only regenerate the colors from the current wallpaper
#   set-wallpaper.sh --restore  start the last video again (wallpaper.sh, at startup)
# Images are shown by awww. Videos (mp4, webm, mkv, mov) play with mpvpaper, looping and muted;
# one of their frames is the thumbnail, the source of the colors and the lock screen background,
# and is also set in awww, behind the video.

WALLPAPERS="$HOME/Pictures/Wallpapers"
CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/wallpaper"
LAST="$CACHE/last"     # path of the last wallpaper set (awww only remembers images)
theme="$HOME/.config/rofi/launchers/type-2/style-1.rasi"

mkdir -p "$CACHE/frames"

# vibrant + the most saturated color of the image: the default (tonal-spot, most dominant color)
# gives muted pastels that look the same on most wallpapers
colors() {
    matugen image "$1" --type scheme-vibrant --prefer saturation --quiet
}

is_video() {
    case "${1,,}" in *.mp4|*.webm|*.mkv|*.mov) return 0 ;; *) return 1 ;; esac
}

# A still frame of a video (1 s in, or the first frame if it is shorter), cached by path and date
frame() {
    local out
    out="$CACHE/frames/$(printf '%s %s' "$1" "$(stat -c %Y "$1")" | md5sum | cut -c1-16).png"
    if [ ! -f "$out" ]; then
        ffmpeg -loglevel error -ss 1 -i "$1" -frames:v 1 -y "$out" 2>/dev/null ||
            ffmpeg -loglevel error -i "$1" -frames:v 1 -y "$out"
    fi
    echo "$out"
}

play_video() {
    pkill -x mpvpaper
    # -p: pauses while windows cover it. panscan fills the screen (crops instead of black bars)
    setsid -f mpvpaper -p -o "no-audio loop hwdec=auto panscan=1.0" '*' "$1" >/dev/null 2>&1
}

current() {
    awww query 2>/dev/null | sed -n 's/.*currently displaying: image: //p' | head -n 1
}

case "${1:-}" in
    --colors)
        image=$(current)
        [ -f "$image" ] && colors "$image"
        exit ;;
    --restore)
        last=$(cat "$LAST" 2>/dev/null)
        if [ -f "$last" ] && is_video "$last" && command -v mpvpaper >/dev/null; then
            play_video "$last"
        fi
        exit ;;
    "")
        if pgrep -x rofi >/dev/null; then
            pkill -x rofi
            exit 0
        fi
        # Grid of thumbnails: rofi shows each image (or a frame of each video) as the icon of its entry
        name=$(cd "$WALLPAPERS" && find -L . -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' \
                   -o -iname '*.webp' -o -iname '*.gif' -o -iname '*.mp4' -o -iname '*.webm' -o -iname '*.mkv' \
                   -o -iname '*.mov' \) | sed 's|^\./||' | sort | while read -r f; do
                   if is_video "$f"; then icon=$(frame "$WALLPAPERS/$f"); else icon="$WALLPAPERS/$f"; fi
                   printf '%s\0icon\x1f%s\n' "$f" "$icon"
               done | rofi -dmenu -i -p "󰸉" -show-icons \
                   -theme "$theme" \
                   -theme-str 'window { width: 900px; }' \
                   -theme-str 'listview { columns: 3; lines: 2; flow: horizontal; }' \
                   -theme-str 'element { orientation: vertical; }' \
                   -theme-str 'element-icon { size: 160px; }' \
                   -theme-str 'element-text { horizontal-align: 0.5; }' \
                   -theme-str 'entry { placeholder: "Search wallpapers..."; }') || exit 0
        file="$WALLPAPERS/$name" ;;
    *)
        file="$1" ;;
esac

[ -f "$file" ] || { notify-send -a Wallpaper "Wallpaper" "Not found: $file"; exit 1; }
file=$(realpath "$file")

if is_video "$file"; then
    if ! command -v mpvpaper >/dev/null; then
        notify-send -a Wallpaper "Wallpaper" "Videos need mpvpaper (yay -S mpvpaper)"
        exit 1
    fi
    image=$(frame "$file")
    awww img "$image" --transition-type grow --transition-duration 1 --transition-fps 60
    play_video "$file"
else
    image="$file"
    pkill -x mpvpaper
    awww img "$image" --transition-type grow --transition-duration 1 --transition-fps 60
fi

echo "$file" > "$LAST"
colors "$image"
