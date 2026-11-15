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

**SDDM** is the login screen and starts Hyprland by default. Its theme is [SilentSDDM](https://github.com/uiriansan/SilentSDDM) (AUR `sddm-silent-theme`, enabled in `Configs/etc/sddm.conf.d/silent.conf`); change its preset from the waybar menu (󰍜 → *Login screen*) or with `~/.config/hypr/scripts/sddm-preset.sh`: a rofi list of the presets, each one previewed full screen before applying it (asks for the password). The choice is saved in `/etc/sddm-silent-preset` and in `Configs/etc/sddm-silent-preset`, and a pacman hook sets it again after theme updates. The profile picture on the login screen and the lock screen is the image in `Assets/Pictures/pfp/`; after changing it, run `~/dotfiles/Scripts/avatar.sh` (asks for the password: SDDM cannot read the home folder, so the picture is copied to `/usr/share/sddm/faces/`). Logging in unlocks **gnome-keyring**, where VS Code, `gh`, the browser and Discord store their passwords and tokens.

Hyprland also starts: waybar, notifications (swaync), the volume/brightness bubble (swayosd), the night light (hyprsunset, off), hypridle, USB automount, the wallpaper, the polkit agent (password prompts), clipboard history and monitor detection.

## Waybar (top bar)

| Area | Module | Usage |
|---|---|---|
| Left | CPU and memory | The memory tooltip also shows swap (zram) |
| Left | Clock | Click: full date. Tooltip: calendar (scroll to change month, right click for the year view) |
| Center | Workspaces | Click to go to one, scroll for the next |
| Right | 󰑊 | Only while recording the screen. Click: stop and save |
| Right | Tray | Icons of background apps |
| Right | Updates | Only visible when there are updates (pacman or AUR). Click: summary in a terminal. Right click: check again |
| Right | Network | Wi-Fi icon of nm-applet. Click: network menu (see below) |
| Right | Volume | Click: mixer (pavucontrol). Right click: mute. Scroll: volume |
| Right | Microphone | Click: input devices (pavucontrol). Right click: mute. Scroll: mic volume (up to 100 %) |
| Right | Battery | Changes color below 30 % (warning) and 15 % (critical) |
| Right | 󰍜 | Click: controls menu (see below) |
| Right | Notifications | Click: notification panel. Right click: do not disturb |
| Right | ⏻ | Power menu |

`Super + R` restarts the bar. Its config is in `Configs/.config/waybar/`.

## Notifications

swaync, styled after [HyprNova](https://github.com/zDyant/HyprNova). The panel (bell in waybar) has buttons to mute the speakers and the microphone, open the network, Bluetooth and GTK theme settings, a media player and the notification list. Its config is in `Configs/.config/swaync/`: the theme in `themes/nova-dark/`, colors from the wallpaper (see [Wallpaper and colors](#wallpaper-and-colors)). After editing, `swaync-client -R -rs` reloads the config and the CSS (restart `swaync` after adding or removing widgets).

### Network menu

NetworkManager's official applet (`nm-applet --indicator`, started in `hypr/conf/autostart.lua`). Its icon (Wi-Fi signal) sits in the controls pill, where the network module was: a second tray, `tray#network`, that hides every other category. Clicking it opens its menu: available Wi-Fi networks, VPNs, turning Wi-Fi on or off and *Edit Connections*. Waybar draws the menu, so it is styled in `waybar/style.css` (`menu`, `menuitem`) with the wallpaper colors.

### Controls menu

The 󰍜 icon opens a Waybar menu (`waybar/menus/controls.xml`; each item's `id` runs the command with the same key in `menu-actions` of `config.jsonc`):

- **Power profile**: performance, balanced or power saver, and *Show power profile* to see the active one. Waybar builds the menu once, so it can't mark the active profile.
- **Brightness**: up or down 10 %, or 100/75/50/25 %. Monitors without a backlight (desktop) only show a notification saying so.
- **Night light**: off, or warmer colors at 4500, 3500 or 2500 K (**hyprsunset**, started with no color change in `autostart.lua`). It is not kept after a reboot.
- **Login screen**: the SilentSDDM preset picker (see [Login](#login)).
- **Wallpaper**: the wallpaper picker, like `Super + W`.
- **Keybinds**: the cheat sheet, like `Super + /`.

Power profile, brightness and night light go through `waybar/scripts/controls-menu.sh`, which confirms each change with a notification.

### Updates

`waybar/scripts/updates.sh` checks every 30 minutes with `checkupdates` (official repos, without touching the system database) and `yay -Qua` (AUR). The click opens a floating kitty window that checks again and shows the pending count and state per manager, the total and the list of packages with their old and new version, then asks whether to update (`yay -Syu`, which covers both). The icon refreshes when it finishes. To refresh the icon right after updating (e.g. from a shell alias): `pkill -RTMIN+8 waybar`.

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

## Wallpaper and colors

Set by **awww** through `scripts/wallpaper.sh`. Wallpapers live in `Assets/Pictures/Wallpapers/` (linked to `~/Pictures/Wallpapers`). The first time it uses `GirlsFrontline/Leva-simple.png`; after that awww remembers the last one you set.

`Super + W` (or 󰍜 → *Wallpaper* in waybar) opens a grid of the wallpapers, subfolders included (`scripts/set-wallpaper.sh`, or `set-wallpaper.sh <file>`). Videos (`.mp4`, `.webm`, `.mkv`, `.mov`) play with **mpvpaper** on every monitor, looping, muted and paused while windows cover them; one of their frames (cached in `~/.cache/wallpaper/`) is the thumbnail, the source of the colors and the lock screen background. The last wallpaper is remembered, so a video starts again after a reboot. Setting one also **recolors the desktop** with [matugen](https://github.com/InioX/matugen), which builds a Material You palette from the image: waybar, notifications, the volume/brightness bubble, the power menu, rofi, the window borders, GTK apps, Qt and KDE apps (Dolphin), the lock screen and kitty, including its 16 terminal colors: Tokyo Night's red, green, yellow, blue, magenta and cyan blended toward the wallpaper (`custom_colors` in `config.toml`), which the starship prompt also uses. Battery, CPU and other states keep green, yellow and red.

- GTK and Qt apps read the colors when they start, so open ones keep the old colors until restarted (GTK 3 apps update right away). GTK: `gtk-3.0/gtk.css` and `gtk-4.0/gtk.css` import the generated `colors.css` (adw-gtk3 color names, and libadwaita variables). Qt: qt6ct uses the generated scheme in `~/.config/qt6ct/colors/matugen.conf`; KDE apps use `~/.local/share/color-schemes/Matugen.colors`, selected in `kdeglobals` (`[UiSettings] ColorScheme=Matugen`). Dolphin needs the scheme set explicitly (with *Default* it mixes qt6ct and kdeglobals: light background, light text), so `install.sh` sets *Matugen* in `dolphinrc`. If a KDE app shows Breeze colors, pick *Matugen* in its *Settings → Window Color Scheme* menu. Missing color files (first start, or a pull that adds a template) are generated when Hyprland starts (`scripts/wallpaper.sh`).
- Config and templates: `Configs/.config/matugen/` (`config.toml` lists where each template is written and how each app is reloaded).
- The written color files are not versioned (`.gitignore`). `install.sh` generates them from the default wallpaper, and `wallpaper.sh` regenerates them at startup if they are missing (`set-wallpaper.sh --colors`).
- Not recolored: GTK and Qt apps, the SDDM login screen and the waybar calendar.

## Screenshots

- `Print`: select a region and it is copied to the clipboard.
- `Super + Print`: captures the whole screen, copies it and opens it in **satty** to draw, crop or highlight. From satty you can save it or copy it again.
- satty is also the default image viewer.

### Screen recording

`Super + Shift + R` (`scripts/screenrecord.sh`): drag a region, or click a monitor to record all of it. **gpu-screen-recorder** records at 60 fps with the desktop audio, encoding on the GPU (VA-API on Intel/AMD, NVENC on NVIDIA). While it records, a red dot shows in waybar; press the shortcut again or click the dot to stop. The video is saved to `~/Videos/Recordings/<date>_<time>.mp4` and a notification shows a thumbnail. Region selection and the thumbnail follow HyDE's `screenrecord.sh`.

## Clipboard

**cliphist** keeps a history of everything you copy (text and images). `Super + V` opens it in rofi (`hypr/scripts/clipboard.sh`, launcher `type-2` with `style-1`); the entry you pick goes back to the clipboard. Pressing it again closes it. The **Clear** button next to the search (or `Alt + Delete`) wipes the whole history and what is copied now.

## Keyboard and input

- **US international with AltGr** layout: a US keyboard with the Spanish characters on `AltGr` (see [Keybindings](keybindings.md#spanish-characters)).
- Mouse without acceleration, and a three-finger touchpad swipe to switch workspaces.

## Devices

- **USB and external drives**: udiskie mounts them automatically and shows a notification. While one is plugged in, a tray icon lets you open or eject it. NTFS and exFAT are supported.
- **Bluetooth**: blueman, from the tray.
- **Audio**: PipeWire. `pavucontrol` (click the volume in waybar) to pick outputs and inputs.
- **Volume and brightness keys**: show a bubble near the bottom of the screen (**swayosd**, `Configs/.config/swayosd/`, wallpaper colors). Volume stops at 100 %. Brightness goes through `brightnessctl -e4`, the same scale as the waybar menu, and swayosd only displays it.
- **Power**: power-profiles-daemon, from the waybar menu (󰍜 in the controls pill).

## Look

- **Windows**: gradient borders in the wallpaper's colors, rounded corners, transparency (95 % for the active window, 85 % for the rest) and blur. Games, Steam, Godot and Blender are always opaque.
- **GTK apps**: `adw-gtk3-dark` theme and global dark mode (change it with `nwg-look`).
- **Qt/KDE apps** (Dolphin, Ark): dark Breeze through `qt6ct`.
- **Terminal**: kitty with colors from the wallpaper (Tokyo Night as the fallback), a semi-transparent background and the CaskaydiaCove Nerd Font.
- **Launcher**: rofi with the themes from [adi1090x/rofi](https://github.com/adi1090x/rofi) (`Configs/.config/rofi/`), using `type-4` with `style-7` (`menu` in `hypr/conf/vars.lua`).
- **Power menu**: `Super + M` and the ⏻ button open wlogout (`hypr/scripts/power-menu.sh`, set as `powerMenu` in `hypr/conf/vars.lua` and `custom/power` in waybar), with the look of [HyprNova](https://github.com/zDyant/HyprNova) (`Configs/.config/wlogout/`). Buttons: shutdown (`s`), reboot (`r`), log out (`e`), suspend (`u`) and lock (`l`); `Esc` or running it again closes it. wlogout has no text widget, so the script draws the "Goodbye / Uptime" header as an SVG above the buttons.

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

Change them in `Configs/.config/hypr/conf/vars.lua` (keybindings). What other programs open through `xdg-open` (Steam's "Browse local files", downloads, links to folders) is set separately with `xdg-mime` in `install.sh`: folders with Dolphin, images with satty. Check one with `xdg-mime query default inode/directory`.
