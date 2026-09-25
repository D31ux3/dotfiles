-- See https://wiki.hypr.land/Configuring/Basics/Binds/

local vars    = require("conf.vars")
local mainMod = vars.mainMod

local function key(k)
    return mainMod .. " + " .. k
end

-- Apps y ventanas
hl.bind(key("T"), hl.dsp.exec_cmd(vars.terminal))
hl.bind(key("Q"), hl.dsp.window.close())
hl.bind(key("M"), hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(key("E"), hl.dsp.exec_cmd(vars.fileManager))
hl.bind(key("V"), hl.dsp.window.float({ action = "toggle" }))
hl.bind(key("A"), hl.dsp.exec_cmd(vars.menu .. " || pkill rofi"))
hl.bind(key("P"), hl.dsp.window.pseudo())
hl.bind(key("J"), hl.dsp.layout("togglesplit")) -- dwindle only
hl.bind(key("R"), hl.dsp.exec_cmd("~/.config/waybar/launch.sh"))

-- Mover el foco con mainMod + flechas
hl.bind(key("left"),  hl.dsp.focus({ direction = "left" }))
hl.bind(key("right"), hl.dsp.focus({ direction = "right" }))
hl.bind(key("up"),    hl.dsp.focus({ direction = "up" }))
hl.bind(key("down"),  hl.dsp.focus({ direction = "down" }))

-- Workspaces: mainMod + [0-9] cambia, mainMod + SHIFT + [0-9] mueve la ventana
for i = 1, 10 do
    local n = i % 10 -- 10 -> tecla 0
    hl.bind(key(n),              hl.dsp.focus({ workspace = i }))
    hl.bind(key("SHIFT + " .. n), hl.dsp.window.move({ workspace = i }))
end

-- Scratchpad
hl.bind(key("S"),         hl.dsp.workspace.toggle_special("magic"))
hl.bind(key("SHIFT + S"), hl.dsp.window.move({ workspace = "special:magic" }))

-- Recorrer workspaces con mainMod + scroll
hl.bind(key("mouse_down"), hl.dsp.focus({ workspace = "e+1" }))
hl.bind(key("mouse_up"),   hl.dsp.focus({ workspace = "e-1" }))

-- Mover/redimensionar con mainMod + click izquierdo/derecho
hl.bind(key("mouse:272"), hl.dsp.window.drag(),   { mouse = true })
hl.bind(key("mouse:273"), hl.dsp.window.resize(), { mouse = true })

-- Volumen y brillo
local media = { locked = true, repeating = true }
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), media)
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),      media)
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),     media)
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),   media)
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                  media)
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                  media)

-- Reproducción (requiere playerctl)
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
