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
        -theme-str 'entry { placeholder: "Buscar"; }'
}

rofi_password() {
    rofi -dmenu -password -p "Contraseña" -mesg "Contraseña para <b>$1</b>" \
        -theme "$theme" \
        -theme-str 'window { width: 550px; }' \
        -theme-str 'element-icon { enabled: false; }' \
        -theme-str 'inputbar { children: [ "textbox-prompt-colon", "entry" ]; }' \
        -theme-str 'entry { placeholder: "Contraseña"; width: 350px; }' \
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

connect_wifi() {
    local ssid="$1" secured="$2"

    # Known network: reuse the saved profile
    if nmcli -t -e no -f NAME,TYPE connection show | grep -Fxq "$ssid:802-11-wireless"; then
        if nmcli connection up id "$ssid" >/dev/null 2>&1; then
            notify "Conectado" "$ssid"
        else
            notify "No se pudo conectar" "$ssid"
        fi
        return
    fi

    if [[ $secured == 1 ]]; then
        local password
        password=$(rofi_password "$ssid") || return
        [[ -z $password ]] && return
        if nmcli device wifi connect "$ssid" password "$password" >/dev/null 2>&1; then
            notify "Conectado" "$ssid"
        else
            # nmcli keeps the profile even on failure; drop it so the next try asks again
            nmcli connection delete id "$ssid" >/dev/null 2>&1
            notify "No se pudo conectar" "$ssid (¿contraseña incorrecta?)"
        fi
    else
        if nmcli device wifi connect "$ssid" >/dev/null 2>&1; then
            notify "Conectado" "$ssid"
        else
            notify "No se pudo conectar" "$ssid"
        fi
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
        add "$icon_wifi_off  Apagar Wi-Fi" "wifi-off"
    else
        add "$icon_wifi_on  Encender Wi-Fi" "wifi-on"
    fi
fi

# Wired devices
while IFS=: read -r dev type state conn; do
    [[ $type == ethernet ]] || continue
    if [[ $state == connected ]]; then
        add "$icon_ethernet  $conn ($dev)  $icon_check" "wired-down:$dev"
    else
        add "$icon_ethernet  $dev (desconectado)" "wired-up:$dev"
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

add "$icon_settings  Configuración avanzada" "settings"

# Current status line
active=$(nmcli -t -e no -f NAME connection show --active | grep -vx lo | head -n1)
mesg="Conectado a: <b>${active:-ninguna red}</b>"

choice=$(printf '%s\n' "${labels[@]}" | rofi_menu "Red" "$mesg") || exit 0
[[ -z $choice ]] && exit 0
action="${actions[$choice]}"

case "$action" in
    wifi-on)        nmcli radio wifi on ;;
    wifi-off)       nmcli radio wifi off ;;
    wifi-down)      nmcli device disconnect "$wifi_dev" >/dev/null && notify "Wi-Fi desconectado" ;;
    wifi-connect:*) rest="${action#wifi-connect:}"; connect_wifi "${rest#*:}" "${rest%%:*}" ;;
    wired-up:*)     nmcli device connect "${action#wired-up:}" >/dev/null && notify "Cable conectado" "${action#wired-up:}" ;;
    wired-down:*)   nmcli device disconnect "${action#wired-down:}" >/dev/null && notify "Cable desconectado" "${action#wired-down:}" ;;
    settings)       nm-connection-editor & ;;
esac
