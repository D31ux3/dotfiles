#!/bin/bash
# Keybinding cheat sheet (mainMod + /): every bind that has a description in conf/keybinds.lua,
# read from the running Hyprland (hyprctl binds), so it always matches the config.
# Descriptions are "Category: text"; they are grouped by category, in the order they appear.
# Type to search. Pressing it again (or Esc) closes it.

theme="$HOME/.config/rofi/launchers/type-2/style-1.rasi"

if pgrep -x rofi >/dev/null; then
    pkill -x rofi
    exit 0
fi

hyprctl binds -j | jq -r '
    # Modifier mask -> names, in the usual order
    def mods: [ (if . / 64 % 2 >= 1 then "Super" else empty end),
                (if . / 4  % 2 >= 1 then "Ctrl"  else empty end),
                (if . / 8  % 2 >= 1 then "Alt"   else empty end),
                (if . % 2 == 1      then "Shift" else empty end) ];
    def keyname: {
        "left": "←", "right": "→", "up": "↑", "down": "↓",
        "slash": "/", "Tab": "Tab", "Print": "Print", "1": "1 … 0",
        "mouse:272": "Left drag", "mouse:273": "Right drag",
        "mouse_up": "Scroll up", "mouse_down": "Scroll down",
        "XF86AudioRaiseVolume": "Media keys"
    }[.] // .;
    [ .[] | select(.has_description) ] | to_entries
    | map(.value.description as $d
          | ($d | split(": ")) as $p
          | { order: .key,
              cat: (if ($p | length) > 1 then $p[0] else "Other" end),
              text: (if ($p | length) > 1 then ($p[1:] | join(": ")) else $d end),
              keys: ((.value.modmask | floor | mods) + [ .value.key | keyname ] | join(" + ")) })
    # Categories in the order they first appear, binds in config order inside each one
    | group_by(.cat) | sort_by(.[0].order) | .[]
    | (.[0].cat | ascii_upcase), (.[] | "  \(.keys)\t\(.text)"), ""
' | awk -F'\t' '
    # Pad the key column so the descriptions line up (the rofi font is monospace)
    NF == 2 { printf "%-30s%s\n", $1, $2; next } { print }
' | rofi -dmenu -i -p "" \
    -theme "$theme" \
    -theme-str 'window { width: 760px; }' \
    -theme-str 'listview { lines: 26; }' \
    -theme-str 'element { padding: 3px 10px; }' \
    -theme-str 'element-icon { enabled: false; }' \
    -theme-str 'entry { placeholder: "Search keybindings..."; }' \
    >/dev/null
exit 0
