# Desktop

[← Back to README](../README.md)

The desktop is **Hyprland**, a tiling window manager for Wayland. Its config is written in Lua and split across `Configs/.config/hypr/conf/`, one file per topic:

| File | Contents |
|---|---|
| `vars.lua` | Default programs (terminal, browser, file manager, launcher) and the `Super` key |
| `monitors.lua` | General monitor rules |
| `env.lua` | Environment variables (cursor, Qt theme, Electron apps on Wayland) |
| `autostart.lua` | What starts on login |
| `look.lua` | Borders, gaps, transparency, blur, animations, tearing and VRR |
| `input.lua` | Keyboard, mouse and touchpad |
| `keybinds.lua` | Keybindings (see [Keybindings](keybindings.md)) |
| `rules.lua` | Per-window rules (floating, games, idle) |

If a config has errors, `hyprctl configerrors` shows the file and line. Hyprland reloads changes as soon as you save.

## Login

**SDDM** is the login screen and starts Hyprland by default. Logging in unlocks **gnome-keyring**, where VS Code, `gh`, the browser and Discord store their passwords and tokens.

Hyprland also starts: waybar, notifications (swaync), hypridle, USB automount, the wallpaper, the polkit agent (password prompts), clipboard history and monitor detection.

## Waybar (top bar)

| Area | Module | Usage |
|---|---|---|
| Left | CPU and memory | The memory tooltip also shows swap (zram) |
| Left | Clock | Click: full date. Tooltip: calendar (scroll to change month, right click for the year view) |
| Center | Workspaces | Click to go to one, scroll for the next |
| Right | Tray | Icons of background apps |
| Right | Volume | Click: mixer (pavucontrol). Right click: mute. Scroll: volume |
| Right | Network | Click: network menu (see below) |
| Right | Battery | Changes color below 30 % (warning) and 15 % (critical) |
| Right | Power profile | Click: cycles power saver, balanced and performance |
| Right | Notifications | Click: notification panel. Right click: do not disturb |
| Right | ⏻ | Power menu |

`Super + R` restarts the bar. Its config is in `Configs/.config/waybar/`.

### Network menu

A rofi menu (`waybar/scripts/network-menu.sh`) built on NetworkManager: turn Wi-Fi on or off, list networks with their signal strength and whether they need a password, connect (asks for the password when needed) and open the advanced settings. Clicking again while it is open closes it.

## Idle, lock and suspend

Handled by **hypridle** (`Configs/.config/hypr/hypridle.conf`):

- **On battery only**: after 5 minutes it dims the screen to the minimum, and after 10 it suspends. With the charger plugged in, or on a desktop PC, it does nothing.
- **It does not act** while audio is playing (music, calls, games), while a window is fullscreen (videos, presentations) or while a game has focus. That way a controller, which does not count as activity, cannot let the system suspend mid-game.
- **Before suspending** it locks the screen, so resuming asks for the password.

The lock screen is **hyprlock** (`Super + L` or from the power menu).

## Monitors

- Any monitor works when plugged in: native resolution, automatic position and scale 1.
- The first time you plug in a monitor, `scripts/detect-monitors.py` writes a rule for it to `~/.config/hypr/conf/monitors_local.lua` with its current settings and the list of available modes. Edit that rule to change resolution, refresh rate, position or scale. Monitors are matched by brand, model and serial number, so the rule follows the screen whatever port it is plugged into.
- That file is per machine and not in the repo. To detect a monitor again, delete its block.
- VRR (FreeSync/G-Sync) is enabled only for fullscreen windows, on screens that support it.

## Wallpaper

Set by **awww** through `scripts/wallpaper.sh`. Wallpapers live in `Assets/Pictures/Wallpapers/` (linked to `~/Pictures/Wallpapers`). The first time it uses `Lucy-rain.png`; after that awww remembers the last one you set. To change it:

```bash
awww img ~/Pictures/Wallpapers/Leva-simple.png
```

## Screenshots

- `Print`: select a region and it is copied to the clipboard.
- `Super + Print`: captures the whole screen, copies it and opens it in **satty** to draw, crop or highlight. From satty you can save it or copy it again.
- satty is also the default image viewer.

## Clipboard

**cliphist** keeps a history of everything you copy (text and images). `Super + V` opens it in rofi; the entry you pick goes back to the clipboard.

## Keyboard and input

- **US international with AltGr** layout: a US keyboard with the Spanish characters on `AltGr` (see [Keybindings](keybindings.md#spanish-characters)).
- Mouse without acceleration, and a three-finger touchpad swipe to switch workspaces.

## Devices

- **USB and external drives**: udiskie mounts them automatically and shows a notification. While one is plugged in, a tray icon lets you open or eject it. NTFS and exFAT are supported.
- **Bluetooth**: blueman, from the tray.
- **Audio**: PipeWire. `pavucontrol` (click the volume in waybar) to pick outputs and inputs.
- **Power**: power-profiles-daemon, from waybar.

## Look

- **Windows**: cyan-green gradient borders, rounded corners, transparency (95 % for the active window, 85 % for the rest) and blur. Games and Steam are always opaque.
- **GTK apps**: `adw-gtk3-dark` theme and global dark mode (change it with `nwg-look`).
- **Qt/KDE apps** (Dolphin, Ark): dark Breeze through `qt6ct`.
- **Terminal**: kitty with the Tokyo Night theme, a semi-transparent background and the CaskaydiaCove Nerd Font.
- **Launcher**: rofi with the themes from [adi1090x/rofi](https://github.com/adi1090x/rofi) (`Configs/.config/rofi/`), using the `type-7` style.

## Default apps

| Purpose | App |
|---|---|
| Terminal | kitty |
| Browser | Brave Origin (Firefox is installed too) |
| Files | Dolphin (with "Open terminal here" in kitty) |
| Archives | Ark |
| Images | satty |
| Video | mpv |
| Screen recording | OBS Studio |
| Editor | VS Code |

Change them in `Configs/.config/hypr/conf/vars.lua`.
