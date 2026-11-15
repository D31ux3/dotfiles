#!/bin/bash
# Actions of the waybar controls menu (custom/menu, menus/controls.xml), with a notification as feedback:
#   controls-menu.sh power <performance|balanced|power-saver|show>   (show: notify the active one)
#   controls-menu.sh brightness <brightnessctl value: 10%+, 10%-, 50%...>
# The notifications replace each other instead of stacking (swaync "synchronous" hint).

# Active power profile, readable: "Balanced", "Power saver"...
profile_name() {
    case "$(powerprofilesctl get 2>/dev/null)" in
        performance) echo "Performance" ;;
        balanced)    echo "Balanced" ;;
        power-saver) echo "Power saver" ;;
        *)           echo "Unavailable" ;;
    esac
}

notify() {  # notify <tag> <title> <body> [percent]
    local args=(-a "$2" -h "string:x-canonical-private-synchronous:$1")
    [ -n "$4" ] && args+=(-h "int:value:$4")
    notify-send "${args[@]}" "$2" "$3"
}

case "$1" in
    power)
        if [ "$2" = show ]; then
            notify power "Power profile" "$(profile_name)"
        elif powerprofilesctl set "$2"; then
            notify power "Power profile" "$(profile_name)"
        else
            notify power "Power profile" "Could not set $2"
        fi
        ;;
    brightness)
        # -e4: exponential steps, closer to how bright it looks. No backlight (desktop monitors): say so
        if brightnessctl -e4 -n2 set "$2" >/dev/null 2>&1; then
            percent=$(brightnessctl -e4 -m | cut -d, -f4 | tr -d %)
            notify brightness "Brightness" "$percent%" "$percent"
        else
            notify brightness "Brightness" "This screen has no adjustable backlight"
        fi
        ;;
    *)
        echo "usage: $0 power <profile|show> | brightness <value>" >&2
        exit 1
        ;;
esac
