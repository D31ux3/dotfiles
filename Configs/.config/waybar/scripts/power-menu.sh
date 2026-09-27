#!/bin/bash

chosen=$(printf "Shutdown\nReboot" | rofi -dmenu -i "Power")

case "$chosen" in
    "Shutdown") poweroff ;;
    "Reboot") reboot ;;
    *) exit 1 ;;
esac