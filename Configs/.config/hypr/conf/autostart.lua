-- See https://wiki.hypr.land/Configuring/Basics/Autostart/

hl.on("hyprland.start", function()
    -- Dark mode for GTK/libadwaita apps and apps that follow the portal (Firefox, Brave, Electron)
    hl.exec_cmd("gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'")
    hl.exec_cmd("gsettings set org.gnome.desktop.interface gtk-theme 'adw-gtk3-dark'")
    -- Icons for GTK apps and the waybar tray/menus: breeze-dark, the same as Qt apps (Adwaita has no
    -- nm-applet icons, so it fell back to the applet's old color PNGs)
    hl.exec_cmd("gsettings set org.gnome.desktop.interface icon-theme 'breeze-dark'")
    hl.exec_cmd("waybar")
    hl.exec_cmd("swaync")
    -- On-screen bubble for the volume, mute and brightness keys (keybinds.lua)
    hl.exec_cmd("swayosd-server")
    -- Night light, off until picked in the waybar menu (controls-menu.sh night)
    hl.exec_cmd("hyprsunset -i")
    hl.exec_cmd("hypridle")
    -- Automount USB drives with a notification; tray icon (eject/open) only while one is plugged in
    hl.exec_cmd("udiskie --smart-tray --appindicator")
    -- Wi-Fi/VPN menu in the waybar tray (NetworkManager's official applet)
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("~/.config/hypr/scripts/wallpaper.sh")
    -- Polkit authentication agent (password prompts for GUI apps)
    hl.exec_cmd("systemctl --user start plasma-polkit-agent")
    -- Clipboard history for mainMod + V
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
    -- Write a rule for each new monitor into conf/monitors_local.lua
    hl.exec_cmd("~/.config/hypr/scripts/detect-monitors.py")
end)

hl.on("monitor.added", function()
    hl.exec_cmd("~/.config/hypr/scripts/detect-monitors.py")
end)
