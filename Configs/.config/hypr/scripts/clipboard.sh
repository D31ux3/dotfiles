#!/bin/bash
# Clipboard history (cliphist) in rofi, launcher type-2 style-1. Opened with mainMod + V.
# The entry you pick goes back to the clipboard. Pressing again while it is open closes it.
# The "Clear" button next to the search (or Alt + Delete) wipes the whole history.

theme="$HOME/.config/rofi/launchers/type-2/style-1.rasi"

if pgrep -x rofi >/dev/null; then
    pkill -x rofi
    exit 0
fi

choice=$(cliphist list \
    | rofi -dmenu -i -p "󰅌" -display-columns 2 \
        -kb-custom-1 "Alt+Delete" \
        -theme "$theme" \
        -theme-str 'window { width: 600px; }' \
        -theme-str 'element-icon { enabled: false; }' \
        -theme-str 'entry { placeholder: "Search clipboard..."; }' \
        -theme-str 'inputbar { children: [ "prompt", "entry", "button-clear" ]; }' \
        -theme-str 'button-clear { expand: false; background-color: inherit; text-color: inherit; cursor: pointer; }' \
        -theme-str 'button-clear { action: "kb-custom-1"; }' \
        -theme-str 'button-clear { content: "󰆴 Clear (Alt + Del)"; }')
status=$?

case $status in
    0)  # An entry was picked
        [ -n "$choice" ] && cliphist decode <<< "$choice" | wl-copy ;;
    10) # Clear button / Alt + Delete: the history and what is copied now
        cliphist wipe
        wl-copy --clear
        notify-send -a Clipboard "Clipboard" "History cleared" ;;
esac
exit 0
