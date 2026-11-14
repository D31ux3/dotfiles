-- See https://wiki.hypr.land/Configuring/Basics/Binds/
-- Each description ("Category: what it does") is what the cheat sheet shows (mainMod + /,
-- scripts/cheatsheet.sh reads them from `hyprctl binds`). Binds without one are not listed.

local vars    = require("conf.vars")
local mainMod = vars.mainMod

local function key(k)
    return mainMod .. " + " .. k
end

local function desc(text, opts)
    opts = opts or {}
    opts.description = text
    return opts
end

-- Apps and windows
hl.bind(key("T"), hl.dsp.exec_cmd(vars.terminal), desc("Apps: Terminal"))
hl.bind(key("Q"), hl.dsp.window.close(), desc("Windows: Close the window"))
hl.bind(key("B"), hl.dsp.exec_cmd(vars.browser), desc("Apps: Browser"))
hl.bind(key("M"), hl.dsp.exec_cmd(vars.powerMenu), desc("System: Power menu (lock, suspend, log out, reboot, shut down)"))
hl.bind(key("E"), hl.dsp.exec_cmd(vars.fileManager), desc("Apps: File manager"))
hl.bind(key("F"), hl.dsp.window.float({ action = "toggle" }), desc("Windows: Float / tile the window"))
hl.bind(key("A"), hl.dsp.exec_cmd(vars.menu .. " || pkill rofi"), desc("Apps: App launcher"))
hl.bind(key("J"), hl.dsp.layout("togglesplit"), desc("Windows: Split side by side / stacked")) -- dwindle only
hl.bind(key("R"), hl.dsp.exec_cmd("~/.config/waybar/launch.sh"), desc("System: Restart the top bar"))
hl.bind(key("SHIFT + F"), hl.dsp.window.fullscreen(), desc("Windows: Fullscreen"))
hl.bind(key("P"), hl.dsp.window.pin(), desc("Windows: Pin a floating window to every workspace"))
hl.bind(key("C"), hl.dsp.window.center(), desc("Windows: Center a floating window"))
hl.bind(key("L"), hl.dsp.exec_cmd("pidof hyprlock || hyprlock"), desc("System: Lock the screen"))
hl.bind(key("V"), hl.dsp.exec_cmd("~/.config/hypr/scripts/clipboard.sh"), desc("Apps: Clipboard history"))
hl.bind(key("W"), hl.dsp.exec_cmd("~/.config/hypr/scripts/set-wallpaper.sh"), desc("Apps: Wallpaper (also recolors the desktop)"))
hl.bind(key("slash"), hl.dsp.exec_cmd("~/.config/hypr/scripts/cheatsheet.sh"), desc("System: This cheat sheet"))

-- Screenshots: Print = region to clipboard, mainMod + Print = full screen to clipboard and opened in satty (not saved)
hl.bind("Print",        hl.dsp.exec_cmd("grim -g \"$(slurp)\" - | wl-copy"), desc("Screenshots: Region to the clipboard"))
hl.bind(key("Print"),   hl.dsp.exec_cmd("grim - | wl-copy && wl-paste | satty -f - --copy-command wl-copy"), desc("Screenshots: Full screen, to the clipboard and the editor"))

-- Move focus with mainMod + arrow keys
hl.bind(key("left"),  hl.dsp.focus({ direction = "left" }),  desc("Windows: Focus the window to the left"))
hl.bind(key("right"), hl.dsp.focus({ direction = "right" }), desc("Windows: Focus the window to the right"))
hl.bind(key("up"),    hl.dsp.focus({ direction = "up" }),    desc("Windows: Focus the window above"))
hl.bind(key("down"),  hl.dsp.focus({ direction = "down" }),  desc("Windows: Focus the window below"))

-- Move windows with mainMod + SHIFT + arrow keys
hl.bind(key("SHIFT + left"),  hl.dsp.window.move({ direction = "left" }),  desc("Windows: Move the window left"))
hl.bind(key("SHIFT + right"), hl.dsp.window.move({ direction = "right" }), desc("Windows: Move the window right"))
hl.bind(key("SHIFT + up"),    hl.dsp.window.move({ direction = "up" }),    desc("Windows: Move the window up"))
hl.bind(key("SHIFT + down"),  hl.dsp.window.move({ direction = "down" }),  desc("Windows: Move the window down"))

-- Resize windows with mainMod + CTRL + arrow keys (hold to keep resizing)
hl.bind(key("CTRL + left"),  hl.dsp.window.resize({ x = -40, y = 0,   relative = true }), desc("Windows: Narrower (hold)", { repeating = true }))
hl.bind(key("CTRL + right"), hl.dsp.window.resize({ x = 40,  y = 0,   relative = true }), desc("Windows: Wider (hold)",    { repeating = true }))
hl.bind(key("CTRL + up"),    hl.dsp.window.resize({ x = 0,   y = -40, relative = true }), desc("Windows: Shorter (hold)",  { repeating = true }))
hl.bind(key("CTRL + down"),  hl.dsp.window.resize({ x = 0,   y = 40,  relative = true }), desc("Windows: Taller (hold)",   { repeating = true }))

-- Workspaces: mainMod + [0-9] switches, mainMod + SHIFT + [0-9] moves the window without following it.
-- Only workspace 1 has a description, standing for all of them in the cheat sheet
for i = 1, 10 do
    local n = i % 10 -- 10 -> key 0
    hl.bind(key(n),              hl.dsp.focus({ workspace = i }),
        i == 1 and desc("Workspaces: Go to workspace 1-10") or nil)
    hl.bind(key("SHIFT + " .. n), hl.dsp.window.move({ workspace = i, follow = false }),
        i == 1 and desc("Workspaces: Send the window to workspace 1-10") or nil)
end

-- Jump back to the previous workspace
hl.bind(key("Tab"), hl.dsp.focus({ workspace = "previous" }), desc("Workspaces: Back to the previous workspace"))

-- Scratchpad
hl.bind(key("S"),         hl.dsp.workspace.toggle_special("magic"), desc("Workspaces: Show / hide the scratchpad"))
hl.bind(key("SHIFT + S"), hl.dsp.window.move({ workspace = "special:magic", follow = false }), desc("Workspaces: Send the window to the scratchpad"))

-- Cycle through workspaces with mainMod + scroll
hl.bind(key("mouse_up"), hl.dsp.focus({ workspace = "e+1" }), desc("Workspaces: Next workspace"))
hl.bind(key("mouse_down"),   hl.dsp.focus({ workspace = "e-1" }), desc("Workspaces: Previous workspace"))

-- Move/resize with mainMod + left/right click
hl.bind(key("mouse:272"), hl.dsp.window.drag(),   desc("Windows: Drag to move", { mouse = true }))
hl.bind(key("mouse:273"), hl.dsp.window.resize(), desc("Windows: Drag to resize", { mouse = true }))
hl.bind(key("X"), hl.dsp.window.resize(), desc("Windows: Hold and move the mouse to resize", { mouse = true }))

-- Volume and brightness (only one description, for all the media keys)
local media = { locked = true, repeating = true }
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
    desc("Media: Volume, brightness and playback keys work as labeled", { locked = true, repeating = true }))
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
