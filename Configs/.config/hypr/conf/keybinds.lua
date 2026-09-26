-- See https://wiki.hypr.land/Configuring/Basics/Binds/

local vars    = require("conf.vars")
local mainMod = vars.mainMod

local function key(k)
    return mainMod .. " + " .. k
end

-- Apps and windows
hl.bind(key("T"), hl.dsp.exec_cmd(vars.terminal))
hl.bind(key("Q"), hl.dsp.window.close())
hl.bind(key("B"), hl.dsp.exec_cmd(vars.browser))
hl.bind(key("M"), hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(key("E"), hl.dsp.exec_cmd(vars.fileManager))
hl.bind(key("F"), hl.dsp.window.float({ action = "toggle" }))
hl.bind(key("A"), hl.dsp.exec_cmd(vars.menu .. " || pkill rofi"))
hl.bind(key("J"), hl.dsp.layout("togglesplit")) -- dwindle only
hl.bind(key("R"), hl.dsp.exec_cmd("~/.config/waybar/launch.sh"))
hl.bind(key("SHIFT + F"), hl.dsp.window.fullscreen())
hl.bind(key("P"), hl.dsp.window.pin())    -- floating only: follows you across workspaces
hl.bind(key("C"), hl.dsp.window.center()) -- floating only
hl.bind(key("L"), hl.dsp.exec_cmd("pidof hyprlock || hyprlock"))
hl.bind(key("V"), hl.dsp.exec_cmd("cliphist list | rofi -dmenu -p clipboard | cliphist decode | wl-copy"))

-- Screenshots: Print = region to clipboard, SHIFT + Print = full screen to ~/Pictures/Screenshots
hl.bind("Print",         hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("mkdir -p ~/Pictures/Screenshots && grim ~/Pictures/Screenshots/$(date +%Y%m%d-%H%M%S).png"))

-- Move focus with mainMod + arrow keys
hl.bind(key("left"),  hl.dsp.focus({ direction = "left" }))
hl.bind(key("right"), hl.dsp.focus({ direction = "right" }))
hl.bind(key("up"),    hl.dsp.focus({ direction = "up" }))
hl.bind(key("down"),  hl.dsp.focus({ direction = "down" }))

-- Move windows with mainMod + SHIFT + arrow keys
hl.bind(key("SHIFT + left"),  hl.dsp.window.move({ direction = "left" }))
hl.bind(key("SHIFT + right"), hl.dsp.window.move({ direction = "right" }))
hl.bind(key("SHIFT + up"),    hl.dsp.window.move({ direction = "up" }))
hl.bind(key("SHIFT + down"),  hl.dsp.window.move({ direction = "down" }))

-- Resize windows with mainMod + CTRL + arrow keys (hold to keep resizing)
hl.bind(key("CTRL + left"),  hl.dsp.window.resize({ x = -40, y = 0,   relative = true }), { repeating = true })
hl.bind(key("CTRL + right"), hl.dsp.window.resize({ x = 40,  y = 0,   relative = true }), { repeating = true })
hl.bind(key("CTRL + up"),    hl.dsp.window.resize({ x = 0,   y = -40, relative = true }), { repeating = true })
hl.bind(key("CTRL + down"),  hl.dsp.window.resize({ x = 0,   y = 40,  relative = true }), { repeating = true })

-- Workspaces: mainMod + [0-9] switches, mainMod + SHIFT + [0-9] moves the window without following it
for i = 1, 10 do
    local n = i % 10 -- 10 -> key 0
    hl.bind(key(n),              hl.dsp.focus({ workspace = i }))
    hl.bind(key("SHIFT + " .. n), hl.dsp.window.move({ workspace = i, follow = false }))
end

-- Jump back to the previous workspace
hl.bind(key("Tab"), hl.dsp.focus({ workspace = "previous" }))

-- Scratchpad
hl.bind(key("S"),         hl.dsp.workspace.toggle_special("magic"))
hl.bind(key("SHIFT + S"), hl.dsp.window.move({ workspace = "special:magic", follow = false }))

-- Cycle through workspaces with mainMod + scroll
hl.bind(key("mouse_up"), hl.dsp.focus({ workspace = "e+1" }))
hl.bind(key("mouse_down"),   hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize with mainMod + left/right click
hl.bind(key("mouse:272"), hl.dsp.window.drag(),   { mouse = true })
hl.bind(key("mouse:273"), hl.dsp.window.resize(), { mouse = true })
hl.bind(key("X"), hl.dsp.window.resize(), {mouse = true})

-- Volume and brightness
local media = { locked = true, repeating = true }
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), media)
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      media)
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     media)
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   media)
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  media)
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  media)

-- Media playback (requires playerctl)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })


