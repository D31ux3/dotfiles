#!/usr/bin/env bash

## Pending updates for the waybar updates module (official repos + AUR)
##   updates.sh        check and print the module JSON (empty text hides the module)
##   updates.sh menu   open the summary in a new terminal (kitty)
##   updates.sh term   summary + offer to update (runs inside that terminal)

cache="${XDG_RUNTIME_DIR:-/tmp}/waybar-updates"
icon=$'\Uf0baf'   # nf-md-pac_man

check() {
    # $1 = max age in seconds of a previous result that can be reused (default 0: always check)
    # One check at a time: waybar runs this once per bar (one per monitor) at the same moment,
    # and parallel checkupdates fail on the lock of their shared temporary database
    exec 9>"$cache.lock"
    flock 9
    if [[ -f $cache ]] && (( $(date +%s) - $(stat -c %Y "$cache") < ${1:-0} )); then
        exec 9>&-
        return
    fi
    local repo aur repo_rc aur_rc
    # checkupdates syncs a temporary copy of the databases (no root): 0 = updates, 2 = none
    repo=$(checkupdates 2>/dev/null); repo_rc=$?
    # yay -Qua exits 1 both when there is nothing to update and on errors; it only
    # writes to stderr on errors
    aur=$(yay -Qua 2>"$cache.err"); aur_rc=$?
    [[ $aur_rc == 1 && ! -s $cache.err ]] && aur_rc=0
    rm -f "$cache.err"
    # yay appends the age of the update ("[4h48m]"), drop it
    aur=$(sed 's/ \[[^]]*\]$//' <<< "$aur")
    (( repo_rc == 2 )) && repo_rc=0
    { printf 'pacman %s\n' "$repo_rc"; printf '%s\n' "$repo" | sed '/^$/d; s/^/P /'
      printf 'yay %s\n' "$aur_rc";    printf '%s\n' "$aur"  | sed '/^$/d; s/^/A /'
    } > "$cache.tmp" && mv "$cache.tmp" "$cache"
    exec 9>&-
}

count() { grep -c "^$1 " "$cache"; }
status() { awk -v m="$1" '$1 == m { print $2 }' "$cache"; }

state() {
    # $1 = manager, $2 = pending
    if [[ $(status "$1") != 0 ]]; then echo "error"
    elif (( $2 > 0 )); then echo "outdated"
    else echo "up to date"
    fi
}

if [[ -z $1 ]]; then
    check 60
    p=$(count P); a=$(count A); t=$(( p + a ))
    if (( t == 0 )); then
        echo '{"text": ""}'
    else
        printf '{"text": "%s", "tooltip": "Updates: %d (pacman %d, yay %d)", "class": "pending"}\n' \
            "$icon" "$t" "$p" "$a"
    fi
    exit 0
fi

# Clicking again while the window is open closes it
if [[ $1 == menu ]]; then
    if pkill -f 'kitty --class updates-float'; then exit 0; fi
    WAYBAR_UPDATES=1 exec kitty --class updates-float -e "$0" term
fi

# term: summary inside the terminal, fresh check
bold=$'\e[1m'; dim=$'\e[2m'; yellow=$'\e[33m'; green=$'\e[32m'; red=$'\e[31m'; reset=$'\e[0m'

printf '%sChecking for updates...%s' "$dim" "$reset"
check
printf '\r\e[K'
p=$(count P); a=$(count A)

state_color() {
    case $1 in
        outdated) printf '%s%s%s' "$yellow" "$1" "$reset" ;;
        error)    printf '%s%s%s' "$red" "$1" "$reset" ;;
        *)        printf '%s%s%s' "$green" "$1" "$reset" ;;
    esac
}

rows() {
    # $1 = prefix in the cache; prints aligned "name  old -> new"
    grep "^$1 " "$cache" | cut -d' ' -f2- \
        | awk '{ printf "  %-30s %s -> %s\n", $1, $2, $4 }'
}

printf '%s%-9s %-8s %s%s\n' "$bold" "Manager" "Pending" "State" "$reset"
printf '%-9s %-8s %s\n' "pacman" "$p" "$(state_color "$(state pacman "$p")")"
printf '%-9s %-8s %s\n' "yay" "$a" "$(state_color "$(state yay "$a")")"
printf '%s%-9s %s%s\n\n' "$bold" "total" "$(( p + a ))" "$reset"

printf '%spacman%s\n' "$bold" "$reset"
if (( p > 0 )); then rows P; else echo "  nothing to update"; fi
printf '\n%syay%s\n' "$bold" "$reset"
if (( a > 0 )); then rows A; else echo "  nothing to update"; fi
echo

refresh() { pkill -RTMIN+8 waybar; }

if (( p + a == 0 )); then
    refresh
    read -rsn1 -p "Press any key to close"
    exit 0
fi

read -rn1 -p "Update now? [y/N] " answer; echo
if [[ $answer == [yYsS] ]]; then
    yay -Syu
    refresh
    echo
    read -rsn1 -p "Done. Press any key to close"
fi
