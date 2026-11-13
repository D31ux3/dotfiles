-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Qt apps use qt6ct for theming (dark palette, see ~/.config/qt6ct/qt6ct.conf)
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")

-- Electron apps (VS Code, Discord...) run as native Wayland instead of XWayland (blurry when scaled)
hl.env("ELECTRON_OZONE_PLATFORM_HINT", "auto")
