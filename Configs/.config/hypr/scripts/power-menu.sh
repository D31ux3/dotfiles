#!/usr/bin/env bash
# Power menu: wlogout with the HyprNova look (~/.config/wlogout) and a "Goodbye / Uptime"
# header like the rofi powermenu had. wlogout has no text widget, so the header is drawn
# as an SVG and set as the window background, in the free space above the buttons.
# Opened by mainMod + M and the waybar power button. Running it again closes the menu.

if pgrep -x wlogout >/dev/null; then
    pkill -x wlogout
    exit 0
fi

conf="$HOME/.config/wlogout"
run="${XDG_RUNTIME_DIR:-/tmp}/wlogout"
mkdir -p "$run"

# Logical height of the focused monitor: the buttons take the middle 26 %
height=$(hyprctl -j monitors | jq -r '.[] | select(.focused) | .height / .scale | floor')
margin=$(( height * 37 / 100 ))

# Header colors from the wallpaper (matugen writes wlogout/colors.css), Catppuccin if missing
color() { sed -n "s/^@define-color $1 *\(#[0-9a-fA-F]\{6\}\);.*/\1/p" "$conf/colors.css" 2>/dev/null; }
text=$(color text);   text=${text:-#cdd6f4}
muted=$(color muted); muted=${muted:-#a6adc8}

escape() { sed -e 's/&/\&amp;/g' -e 's/</\&lt;/g' -e 's/>/\&gt;/g'; }
goodbye=$(printf 'Goodbye %s' "$USER" | escape)
uptime=$(printf 'Uptime: %s' "$(uptime -p | sed -e 's/up //g')" | escape)

cat > "$run/header.svg" <<SVG
<svg xmlns="http://www.w3.org/2000/svg" width="900" height="110">
  <g font-family="JetBrainsMono Nerd Font, monospace" text-anchor="middle">
    <text x="450" y="48" font-size="38" font-weight="bold" fill="$text">$goodbye</text>
    <text x="450" y="92" font-size="20" fill="$muted">$uptime</text>
  </g>
</svg>
SVG

cat > "$run/style.css" <<CSS
@import url("file://$conf/style.css");
window {
    background-image: url("file://$run/header.svg");
    background-repeat: no-repeat;
    background-position: center $(( margin - 130 ))px;
}
CSS

wlogout -l "$conf/layout" -C "$run/style.css" --protocol layer-shell \
    -b 5 -T "$margin" -B "$margin" &
