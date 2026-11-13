#!/bin/bash
# Clipboard history (cliphist) in rofi, launcher type-2 style-1. Opened with mainMod + V.
# The entry you pick goes back to the clipboard. Pressing again while it is open closes it.

theme="$HOME/.config/rofi/launchers/type-2/style-1.rasi"

if pgrep -x rofi >/dev/null; then
    pkill -x rofi
    exit 0
fi

choice=$(cliphist list \
    | rofi -dmenu -i -p "󰅌" -display-columns 2 \
        -theme "$theme" \
        -theme-str 'window { width: 600px; }' \
        -theme-str 'element-icon { enabled: false; }' \
        -theme-str 'entry { placeholder: "Search clipboard..."; }') || exit 0

[ -n "$choice" ] && cliphist decode <<< "$choice" | wl-copy
