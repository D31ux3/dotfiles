#!/bin/bash
# Session menu (rofi): lock, suspend, log out, reboot, shutdown.
# Opened with mainMod + M and from the power button in waybar.

chosen=$(printf "Lock\nSuspend\nLog out\nReboot\nShutdown" | rofi -dmenu -i -p "Power")

case "$chosen" in
    "Lock") loginctl lock-session ;;      # hypridle runs hyprlock
    "Suspend") systemctl suspend ;;       # hypridle locks before sleeping
    "Log out")
        # hyprshutdown (if installed) closes apps gracefully before exiting
        command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'
        ;;
    "Reboot") reboot ;;
    "Shutdown") poweroff ;;
    *) exit 1 ;;
esac
