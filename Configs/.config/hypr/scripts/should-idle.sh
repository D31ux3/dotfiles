#!/bin/bash
# Exits 0 when hypridle may dim the screen or suspend (condition_cmd in hypridle.conf):
# running on battery (see is-using-battery.sh) and no audio playing (music, a call, a game).
# Fullscreen windows and games block idle on their own (idle_inhibit rules in rules.lua).

"$(dirname "$0")/is-using-battery.sh" || exit 1

# An output (sink) is RUNNING while some app plays sound; paused streams let it go back to IDLE
pactl list sinks short 2>/dev/null | grep -q RUNNING && exit 1

exit 0
