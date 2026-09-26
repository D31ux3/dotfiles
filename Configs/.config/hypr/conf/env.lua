-- See https://wiki.hypr.land/Configuring/Advanced-and-Cool/Environment-variables/

hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- Qt apps use qt6ct for theming (dark palette, see ~/.config/qt6ct/qt6ct.conf)
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
