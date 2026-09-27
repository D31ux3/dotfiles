#!/usr/bin/env bash

## Rofi network menu for the waybar network module (NetworkManager / nmcli)

theme="$HOME/.config/rofi/launchers/type-7/style-1.rasi"

# Nerd Font (Material Design) icons
icon_wifi_on=$'\Uf05a9'       # nf-md-wifi
icon_wifi_off=$'\Uf05aa'      # nf-md-wifi_off
icon_ethernet=$'\Uf0200'      # nf-md-ethernet
icon_settings=$'\Uf0493'      # nf-md-cog
icon_check=$'\Uf012c'         # nf-md-check
icons_signal=($'\Uf091f' $'\Uf0922' $'\Uf0925' $'\Uf0928')  # nf-md-wifi_strength_1..4
icons_signal_lock=($'\Uf0921' $'\Uf0924' $'\Uf0927' $'\Uf092a')  # nf-md-wifi_strength_1..4_lock

# Clicking again while the menu is open closes it
if pgrep -x rofi >/dev/null; then
    pkill -x rofi
    exit 0
fi

notify() {
    command -v notify-send >/dev/null && notify-send -a "Network" "$1" "$2"
}

rofi_menu() {
    # $1 = prompt, $2 = message; entries on stdin; prints selected index
    rofi -dmenu -i -no-custom -format i \
        -p "$1" -mesg "$2" \
        -theme "$theme" \
        -theme-str 'window { width: 550px; }' \
        -theme-str 'element-icon { enabled: false; }' \
        -theme-str 'element { padding: 8px 12px; }' \
        -theme-str 'inputbar { children: [ "textbox-prompt-colon", "entry" ]; }' \
        -theme-str 'entry { placeholder: "Search"; }'
}

rofi_password() {
    rofi -dmenu -password -p "Password" -mesg "Password for <b>$1</b>" \
        -theme "$theme" \
        -theme-str 'window { width: 550px; }' \
        -theme-str 'element-icon { enabled: false; }' \
        -theme-str 'inputbar { children: [ "textbox-prompt-colon", "entry" ]; }' \
        -theme-str 'entry { placeholder: "Password"; width: 350px; }' \
        -theme-str 'listview { enabled: false; }'
}

signal_icon() {
    # $1 = signal 0-100, $2 = secured (1/0)
    local level=$(( $1 / 25 ))
    (( level > 3 )) && level=3
    if [[ $2 == 1 ]]; then
        printf '%s' "${icons_signal_lock[$level]}"
    else
        printf '%s' "${icons_signal[$level]}"
    fi
}

wifi_uuids() {
    nmcli -t -e no -f UUID,TYPE connection show | awk -F: '$2 == "802-11-wireless" { print $1 }'
}

saved_profile() {
    # $1 = SSID; prints the UUID of the most recently used saved profile for it.
    # Matched by SSID, not by name: NetworkManager names duplicates "SSID 1", "SSID 2"...
    local uuid
    for uuid in $(wifi_uuids); do
        [[ $(nmcli -g 802-11-wireless.ssid connection show uuid "$uuid") == "$1" ]] || continue
        printf '%s %s\n' "$(nmcli -g connection.timestamp connection show uuid "$uuid")" "$uuid"
    done | sort -nr | awk 'NR == 1 { print $2 }'
}

connect_wifi() {
    local ssid="$1" secured="$2" uuid iface err

    # Known network: reuse the saved profile
    uuid=$(saved_profile "$ssid")
    if [[ -n $uuid ]]; then
        # Profiles get pinned to the interface they were created on; if the card was
        # renamed (e.g. wlp3s0 -> wlan0) activation fails, so unpin it
        iface=$(nmcli -g connection.interface-name connection show uuid "$uuid")
        if [[ -n $iface && $iface != "$wifi_dev" ]]; then
            nmcli connection modify uuid "$uuid" connection.interface-name ""
        fi
        if err=$(nmcli connection up uuid "$uuid" ifname "$wifi_dev" 2>&1); then
            notify "Connected" "$ssid"
        else
            notify "Connection failed" "$ssid: ${err##*Error: }"
        fi
        return
    fi

    local args=(device wifi connect "$ssid" ifname "$wifi_dev")
    if [[ $secured == 1 ]]; then
        local password
        password=$(rofi_password "$ssid") || return
        [[ -z $password ]] && return
        args+=(password "$password")
    fi

    local before
    before=$(wifi_uuids)
    if err=$(nmcli "${args[@]}" 2>&1); then
        notify "Connected" "$ssid"
    else
        # nmcli keeps the new profile even on failure; drop it so the next try asks again
        for uuid in $(wifi_uuids); do
            grep -Fxq "$uuid" <<< "$before" || nmcli connection delete uuid "$uuid" >/dev/null 2>&1
        done
        notify "Connection failed" "$ssid: ${err##*Error: }"
    fi
}

# Each menu entry has a label and an action at the same index
labels=()
actions=()

add() {
    labels+=("$1")
    actions+=("$2")
}

wifi_dev=$(nmcli -t -e no -f DEVICE,TYPE device | awk -F: '$2 == "wifi" { print $1; exit }')
wifi_state=$(nmcli radio wifi)

# Wi-Fi toggle (only if there is a Wi-Fi card)
if [[ -n $wifi_dev ]]; then
    if [[ $wifi_state == enabled ]]; then
        add "$icon_wifi_off  Turn Wi-Fi off" "wifi-off"
    else
        add "$icon_wifi_on  Turn Wi-Fi on" "wifi-on"
    fi
fi

# Wired devices
while IFS=: read -r dev type state conn; do
    [[ $type == ethernet ]] || continue
    if [[ $state == connected ]]; then
        add "$icon_ethernet  $conn ($dev)  $icon_check" "wired-down:$dev"
    else
        add "$icon_ethernet  $dev (disconnected)" "wired-up:$dev"
    fi
done < <(nmcli -t -e no -f DEVICE,TYPE,STATE,CONNECTION device)

# Wi-Fi networks, strongest first, one entry per SSID
if [[ -n $wifi_dev && $wifi_state == enabled ]]; then
    while IFS=: read -r in_use signal security ssid; do
        [[ -z $ssid ]] && continue
        secured=0
        [[ -n $security && $security != "--" ]] && secured=1
        label="$(signal_icon "$signal" "$secured")  $ssid"
        if [[ $in_use == "*" ]]; then
            add "$label  $icon_check" "wifi-down"
        else
            add "$label" "wifi-connect:$secured:$ssid"
        fi
    done < <(nmcli -t -e no -f IN-USE,SIGNAL,SECURITY,SSID device wifi list --rescan auto \
                | sort -t: -k1,1r -k2,2nr \
                | awk '{ key = $0; for (i = 0; i < 3; i++) sub(/^[^:]*:/, "", key) } !seen[key]++')
fi

add "$icon_settings  Advanced settings" "settings"

# Current status line
active=$(nmcli -t -e no -f NAME connection show --active | grep -vx lo | head -n1)
mesg="Connected to: <b>${active:-no network}</b>"

choice=$(printf '%s\n' "${labels[@]}" | rofi_menu "Network" "$mesg") || exit 0
[[ -z $choice ]] && exit 0
action="${actions[$choice]}"

case "$action" in
    wifi-on)        nmcli radio wifi on && notify "Wi-Fi on" ;;
    wifi-off)       nmcli radio wifi off && notify "Wi-Fi off" ;;
    wifi-down)      nmcli device disconnect "$wifi_dev" >/dev/null && notify "Wi-Fi disconnected" ;;
    wifi-connect:*) rest="${action#wifi-connect:}"; connect_wifi "${rest#*:}" "${rest%%:*}" ;;
    wired-up:*)     nmcli device connect "${action#wired-up:}" >/dev/null && notify "Wired connected" "${action#wired-up:}" ;;
    wired-down:*)   nmcli device disconnect "${action#wired-down:}" >/dev/null && notify "Wired disconnected" "${action#wired-down:}" ;;
    settings)       nm-connection-editor & ;;
esac
