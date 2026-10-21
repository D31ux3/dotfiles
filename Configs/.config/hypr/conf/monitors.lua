-- See https://wiki.hypr.land/Configuring/Basics/Monitors/

-- For specific monitor configuration go to monitors_local.lua

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
-- Loaded with require (not dofile) so Hyprland watches it and reloads when it is saved
local file = io.open(os.getenv("HOME") .. "/.config/hypr/conf/monitors_local.lua")
if file then
    file:close()
    require("conf.monitors_local")
end
