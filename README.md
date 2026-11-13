# dotfiles

A complete desktop environment on **Arch Linux + Hyprland**, built for software development, game development and gaming. A single script turns a fresh install into a ready-to-use system: packages, drivers, configuration and services.

## What's included

- **Hyprland desktop** (Lua config) with waybar, rofi, notifications, idle lock and suspend, a power menu and automatic monitor detection.
- **Automatic GPU drivers**: detects Intel, AMD and NVIDIA (including legacy branches and hybrid laptops) and installs the right ones.
- **Terminal**: kitty + zsh with autosuggestions, syntax highlighting, starship, fzf, zoxide, bat, eza and ripgrep.
- **Development**: C/C++ (clang, cmake, ninja), mise for language versions, .NET, Docker, Git with LFS and delta, and VS Code set up for Wayland.
- **Gaming**: Steam, Lutris, Proton-GE, gamemode, MangoHud, gamescope, Xbox controllers over Bluetooth, and a tuned Hyprland (tearing, VRR, no transparency or screen lock mid-game).
- **Art and audio**: Krita and Audacity.

## Quick install

On a base Arch Linux install:

```bash
sudo pacman -S --needed git base-devel
git clone https://github.com/d31ux3/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

Reboot when it finishes. Details and manual steps are in [docs/instalacion.md](docs/instalacion.md).

## Documentation

The detailed documentation is in Spanish.

| Document | Contents |
|---|---|
| [Installation](docs/instalacion.md) | What `install.sh` does step by step, and what is left to do by hand |
| [Keybindings](docs/atajos.md) | Every Hyprland and terminal shortcut |
| [Desktop](docs/escritorio.md) | Waybar, menus, idle behavior, monitors, screenshots, clipboard, keyboard |
| [Terminal and development](docs/terminal-y-desarrollo.md) | zsh, aliases, tools, Git, mise, Docker, VS Code |
| [Gaming](docs/juegos.md) | Tools, controllers, Hyprland tweaks and how to launch games |
| [Repo structure](docs/estructura.md) | How it is organized and how to add packages or configs |
