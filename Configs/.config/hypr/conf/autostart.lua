-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

hl.on("hyprland.start", function()
    -- Dark mode for GTK/libadwaita apps and apps that follow the portal (Firefox, Brave, Electron)
    hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'")
    hl.exec_cmd("waybar")
    hl.exec_cmd("swaync")
    hl.exec_cmd("hypridle")
    -- Automount USB drives with a notification; tray icon (eject/open) only while one is plugged in
    hl.exec_cmd("udiskie --smart-tray --appindicator")
    hl.exec_cmd("~/.config/hypr/scripts/wallpaper.sh")
    -- Polkit authentication agent (password prompts for GUI apps)
    hl.exec_cmd("systemctl --user start plasma-polkit-agent")
    -- Clipboard history for mainMod + V
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)
