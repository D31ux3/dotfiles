# Keybindings

[← Back to README](../README.md)

`Super` is the Windows key. Bindings are defined in `Configs/.config/hypr/conf/keybinds.lua`.

## Apps

| Shortcut | Action |
|---|---|
| `Super + T` | Terminal (kitty) |
| `Super + B` | Browser (Brave Origin) |
| `Super + E` | File manager (Dolphin) |
| `Super + A` | App launcher (rofi). Press again to close it |
| `Super + V` | Clipboard history |
| `Super + W` | Pick a wallpaper (also recolors the desktop) |
| `Super + M` | Power menu: lock, suspend, log out, reboot, shut down |
| `Super + L` | Lock the screen |
| `Super + R` | Restart waybar (if it hangs or after editing its config) |

## Windows

| Shortcut | Action |
|---|---|
| `Super + Q` | Close the window |
| `Super + F` | Toggle floating / tiled |
| `Super + Shift + F` | Fullscreen |
| `Super + J` | Toggle the split direction (horizontal / vertical) |
| `Super + P` | Pin a floating window: it follows you to every workspace |
| `Super + C` | Center a floating window |
| `Super + ←↑→↓` | Move focus |
| `Super + Shift + ←↑→↓` | Move the window |
| `Super + Ctrl + ←↑→↓` | Resize (hold to keep resizing) |
| `Super + left click` (drag) | Move the window |
| `Super + right click` (drag) | Resize the window |

## Workspaces

| Shortcut | Action |
|---|---|
| `Super + 1…0` | Go to workspace 1…10 |
| `Super + Shift + 1…0` | Send the window to that workspace (without following it) |
| `Super + Tab` | Back to the previous workspace |
| `Super + mouse wheel` | Next / previous workspace |
| Three-finger horizontal swipe (touchpad) | Switch workspace |
| `Super + S` | Show or hide the *scratchpad* (hidden floating workspace) |
| `Super + Shift + S` | Send the window to the scratchpad |

## Screenshots

| Shortcut | Action |
|---|---|
| `Print` | Capture a region to the clipboard |
| `Super + Print` | Capture the whole screen and open it in satty to annotate it |

## Media keys

They also work on the lock screen.

| Key | Action |
|---|---|
| Volume + / − | Raise / lower 5 % (max 100 %) |
| Mute | Mute the audio output |
| Mic mute | Mute the microphone |
| Brightness + / − | Raise / lower brightness |
| Play / Pause, Next, Previous | Control the active player (playerctl) |

## Spanish characters

The layout is US international with AltGr dead keys: regular keys are those of a US keyboard, and Spanish characters come from `AltGr` (right Alt).

| Shortcut | Character |
|---|---|
| `AltGr + n` | ñ |
| `AltGr + a` / `e` / `i` / `o` / `u` | á é í ó ú |
| `AltGr + /` | ¿ |
| `AltGr + Shift + 1` | ¡ |
| `AltGr + '` then the vowel | Acute accent on any vowel (also ü with `AltGr + "`) |

## Terminal (zsh)

| Shortcut | Action |
|---|---|
| `Ctrl + R` | Search command history (fzf) |
| `Ctrl + T` | Find a file and insert its path, with preview |
| `Alt + C` | Find a folder and cd into it |
| `→` | Accept the gray suggestion (from history) |
| `Ctrl + →` | Accept only the next word of the suggestion |
| `Ctrl + X`, `Ctrl + E` | Edit the current command in the editor (VS Code) |
