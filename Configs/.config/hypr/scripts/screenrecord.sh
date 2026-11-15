#!/bin/bash
# Screen recording with gpu-screen-recorder (GPU encoding: VA-API on Intel/AMD, NVENC on NVIDIA),
# with desktop audio. Saved to ~/Videos/Recordings/<date>_<time>.mp4.
#   screenrecord.sh          not recording: drag a region, or click a monitor to record all of it
#                            (Esc cancels). Recording: stop and save. (mainMod + Shift + R)
#   screenrecord.sh status   JSON for waybar's custom/recording: a red dot while recording (click it to stop)
# Region selection and the thumbnail in the final notification follow HyDE's screenrecord.sh.

dir="${XDG_VIDEOS_DIR:-$HOME/Videos}/Recordings"
state="${XDG_RUNTIME_DIR:-/tmp}/screenrecord"   # .pid, .file: path being recorded, .png: thumbnail, .log: errors

refresh() { pkill -RTMIN+10 -x waybar; }
# By PID: the process name is too long for pgrep -x (the kernel keeps 15 characters)
recording() { kill -0 "$(cat "$state.pid" 2>/dev/null)" 2>/dev/null; }

case "$1" in
    status)
        if recording; then
            printf '{"text": "󰑊", "class": "recording", "tooltip": "Recording the screen: click (or mainMod + Shift + R) to stop"}\n'
        else
            printf '{"text": ""}\n'
        fi
        exit 0
        ;;
esac

if recording; then
    # SIGINT makes it finish the file properly; wait for it so the notification comes once it is saved
    kill -INT "$(cat "$state.pid")"
    for _ in $(seq 50); do recording || break; sleep 0.1; done
    file=$(cat "$state.file" 2>/dev/null)
    notify-send -a "Screen recording" -i "$state.png" "Recording saved" "${file/#$HOME/\~}"
    refresh
    exit 0
fi

# x y w h of the selection; with -o a click selects the whole monitor under the cursor.
# Into a variable first: slurp prints no final newline, which makes `read` fail
selection=$(slurp -o -f "%x %y %w %h") || exit 0   # Esc: cancelled
read -r x y w h <<< "$selection"

mkdir -p "$dir"
file="$dir/$(date +%Y-%m-%d_%H-%M-%S).mp4"
echo "$file" > "$state.file"
grim -g "$x,$y ${w}x$h" "$state.png"   # thumbnail for the notification at the end

gpu-screen-recorder -w region -region "${w}x$h+$x+$y" -f 60 -a default_output \
    -o "$file" >/dev/null 2>"$state.log" &
echo $! > "$state.pid"
disown
sleep 0.5
if ! recording; then
    notify-send -a "Screen recording" -u critical "Could not start the recording" "$(tail -n 3 "$state.log")"
    exit 1
fi
refresh
