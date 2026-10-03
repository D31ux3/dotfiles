#!/bin/bash
# Exits 0 when the computer is running on its battery, 1 otherwise.
# Used as condition_cmd in hypridle.conf, so dimming and suspend only happen on battery.
# A desktop (no battery) or a laptop plugged in counts as "not on battery".

on_battery=1

for supply in /sys/class/power_supply/*; do
    case "$(cat "$supply/type" 2>/dev/null)" in
        Mains|USB)
            # Charger plugged in
            [ "$(cat "$supply/online" 2>/dev/null)" = "1" ] && exit 1
            ;;
        Battery)
            # scope=Device is a peripheral's battery (Bluetooth mouse, headset...), not the laptop's
            [ "$(cat "$supply/scope" 2>/dev/null)" = "Device" ] && continue
            on_battery=0
            ;;
    esac
done

exit $on_battery
