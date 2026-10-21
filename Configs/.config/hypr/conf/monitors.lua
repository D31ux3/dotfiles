-- See https://wiki.hypr.land/Configuring/Basics/Monitors/

-- For specific monitor configuration go to monitors.local.lua

-- Any monitor: its native mode and scale, so it works with whatever screen is plugged in
hl.monitor({
    output   = "", -- Monitor - See them with: hyprctl monitors all
    mode     = "preferred",
    position = "auto",
    scale    = 1,
})

-- Virtual machines (virtio-gpu reports a 1280x800 preferred mode, not the window size)
hl.monitor({
    output   = "Virtual-1",
    mode     = "1920x1080",
    position = "auto",
    scale    = 1,
})

-- Per-monitor rules for this machine, written by scripts/detect-monitors.py (not versioned)
local localRules = os.getenv("HOME") .. "/.config/hypr/conf/monitors.local.lua"
local file = io.open(localRules)
if file then
    file:close()
    dofile(localRules)
end
