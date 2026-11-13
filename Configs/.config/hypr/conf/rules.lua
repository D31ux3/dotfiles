-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- and https://wiki.hypr.land/Configuring/Basics/Workspace-Rules/

hl.window_rule({
    -- Ignore maximize requests from all apps
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    -- Fix dragging issues with XWayland windows
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

hl.window_rule({
    name  = "move-hyprland-run",
    match = { class = "hyprland-run" },

    move  = "20 monitor_h-120",
    float = true,
})

hl.window_rule({
    name  = "pavucontrol-float",
    match = { class = "^org\\.pulseaudio\\.pavucontrol$" },

    float  = true,
    size   = "600 400",
    center = true,
})

hl.window_rule({
    -- Waybar updates summary (waybar/scripts/updates.sh)
    name  = "updates-float",
    match = { class = "^updates-float$" },

    float  = true,
    size   = "800 500",
    center = true,
})

hl.window_rule({
    name  = "satty-float",
    match = { class = "com.gabm.satty"},
    
    float  = true,
    size   = "1280 720",
    center = true,
})

hl.window_rule({
    name  = "mpv-float",
    match = { class = "mpv"},

    float  = true,
    size   = "1280 720",
    center = true,
})

-- Games: Steam games (steam_app_<id>), anything run through gamescope,
-- and windows that declare themselves a game (content-type, e.g. some native and Proton games)
local games = {
    { class = "^(steam_app_\\d+|gamescope)$" },
    { content = "game" },
}
for i, match in ipairs(games) do
    hl.window_rule({
        name  = "game-" .. i,
        match = match,

        immediate    = true,          -- tearing allowed (general.allow_tearing), less input lag
        opacity      = "1 override",  -- ignore active/inactive_opacity
        idle_inhibit = "focus",       -- a controller does not count as activity for hypridle
    })
end

hl.window_rule({
    -- Steam and apps where transparency gets in the way (game editor, also its running game).
    -- Tools launched from Steam keep their own class, not steam_app_<id>, so they are listed here
    name  = "opaque-apps",
    match = { class = "^(steam|Godot|blender)$" },

    opacity = "1 override",
})

hl.window_rule({
    -- No dimming or suspend while something is fullscreen (videos, games, presentations)
    name  = "fullscreen-idle-inhibit",
    match = { class = ".*" },

    idle_inhibit = "fullscreen",
})

-- See https://wiki.hypr.land/Configuring/Basics/Window-Rules/#layer-rules
hl.layer_rule({
    name  = "waybar-blur",
    match = { namespace = "waybar" },

    blur = false,
})

hl.layer_rule({
    -- Blur behind rofi menus (launcher, powermenu...): their backgrounds are mostly
    -- transparent and unreadable over the wallpaper without it
    name  = "rofi-blur",
    match = { namespace = "rofi" },

    blur        = true,
    ignore_alpha = 0,
})
