#!/bin/bash
# Picks the SilentSDDM login screen preset (https://github.com/uiriansan/SilentSDDM) in rofi.
# The chosen preset is previewed with SDDM's test mode, and applying it asks for the password
# (polkit) to set ConfigFile= in the theme's metadata.desktop and save it to /etc/sddm-silent-preset,
# which a pacman hook (Configs/etc/pacman.d/hooks/sddm-silent-preset.hook) restores after updates.
# The choice is also written to the dotfiles (Configs/etc/sddm-silent-preset) for new installs.

themedir=/usr/share/sddm/themes/silent
theme="$HOME/.config/rofi/launchers/type-2/style-1.rasi"
dotfiles_preset="$(dirname "$(readlink -f "$0")")/../../../etc/sddm-silent-preset"

if [ ! -d "$themedir" ]; then
    notify-send -a "Login screen" "Login screen" "SilentSDDM is not installed (yay -S sddm-silent-theme)"
    exit 1
fi

if pgrep -x rofi >/dev/null; then
    pkill -x rofi
    exit 0
fi

menu() { # prompt placeholder: reads the options from stdin, prints the choice
    rofi -dmenu -i -p "󰍹" \
        -theme "$theme" \
        -theme-str 'window { width: 500px; }' \
        -theme-str 'element-icon { enabled: false; }' \
        -theme-str "entry { placeholder: \"$1\"; }"
}

current=$(sed -n 's|^ConfigFile=configs/\(.*\)\.conf$|\1|p' "$themedir/metadata.desktop")

# Preview: a copy of the theme made of symlinks, with its own metadata.desktop
preview_dir="${XDG_RUNTIME_DIR:-/tmp}/sddm-preset-preview"
preview_pid=

stop_preview() {
    [ -n "$preview_pid" ] && kill "$preview_pid" 2>/dev/null
    preview_pid=
}
trap stop_preview EXIT

start_preview() {
    rm -rf "$preview_dir"
    mkdir -p "$preview_dir"
    for f in "$themedir"/*; do
        [ "$(basename "$f")" = metadata.desktop ] || ln -s "$f" "$preview_dir/"
    done
    sed "s|^ConfigFile=.*|ConfigFile=configs/$1.conf|" "$themedir/metadata.desktop" > "$preview_dir/metadata.desktop"
    (cd "$preview_dir" && QT_IM_MODULE=qtvirtualkeyboard QML2_IMPORT_PATH=./components/ \
        exec sddm-greeter-qt6 --test-mode --theme .) >/dev/null 2>&1 &
    preview_pid=$!
    sleep 1.5
}

while true; do
    preset=$(for f in "$themedir"/configs/*.conf; do
                 name=$(basename "$f" .conf)
                 [ "$name" = "$current" ] && echo "$name  (current)" || echo "$name"
             done | menu "Login screen preset...") || exit 0
    preset=${preset%  (current)}
    [ -f "$themedir/configs/$preset.conf" ] || exit 1

    start_preview "$preset"
    answer=$(printf 'Apply\nBack\nCancel' | menu "Apply $preset?")
    stop_preview

    case $answer in
        Apply) break ;;
        Back)  continue ;;
        *)     exit 0 ;;
    esac
done

if pkexec sh -c 'sed -i "s|^ConfigFile=.*|ConfigFile=configs/$1.conf|" "$2/metadata.desktop" &&
                 echo "$1" > /etc/sddm-silent-preset' sh "$preset" "$themedir"; then
    [ -f "$dotfiles_preset" ] && echo "$preset" > "$dotfiles_preset"
    notify-send -a "Login screen" "Login screen" "Preset $preset applied"
else
    notify-send -a "Login screen" "Login screen" "Preset not changed"
fi
