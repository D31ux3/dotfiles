# Repo structure

[← Back to README](../README.md)

```
dotfiles/
├── install.sh              Full install (see installation.md)
├── pkglist.txt             Official packages, grouped in sections
├── aurlist.txt             AUR packages
├── vscode-extensions.txt   VS Code extensions
├── todo.txt                Pending tasks for the environment
├── Scripts/
│   ├── gpu-drivers.sh      Detects the GPU and installs its drivers
│   └── link.sh             Links the configs into ~
├── Configs/
│   ├── .zshrc              → ~/.zshrc
│   ├── .config/            → each item to ~/.config/<name>
│   │   ├── hypr/           Hyprland, hypridle, hyprlock and their scripts
│   │   ├── waybar/
│   │   ├── rofi/
│   │   ├── swaync/         Notifications (HyprNova style)
│   │   ├── kitty/
│   │   ├── Code/User/settings.json
│   │   └── ...
│   └── etc/                → copied to /etc (system files)
├── Assets/Pictures/       → each folder to ~/Pictures/<name> (Wallpapers, pfp)
└── docs/                   This documentation
```

## How configs are applied

`Scripts/link.sh` creates **symlinks** from your home folder into the repo:

- Each file or folder in `Configs/` goes to `~/` (e.g. `Configs/.zshrc` → `~/.zshrc`).
- Each item in `Configs/.config/` goes to `~/.config/` one by one, so `~/.config` stays a regular folder for every other program.
- **VS Code** is the exception: only `settings.json` is linked, because its folder holds cache and history that do not belong in the repo.

Since they are links, **editing `~/.config/...` edits the repo**: changes show up in `git status`, ready to commit.

If a real file already exists at the destination, `link.sh` moves it to `~/.dotfiles-backup/<date>/` before linking. It is safe to run as many times as needed.

### System files (`Configs/etc`)

Files in `Configs/etc/` are **copied** to `/etc` as root; they are not linked, because the system reads them before you log in. That is why **after editing them you have to copy them again**:

```bash
sudo install -Dm644 ~/dotfiles/Configs/etc/systemd/zram-generator.conf /etc/systemd/zram-generator.conf
```

(or run `install.sh` again). For now it only holds the zram config (compressed swap in RAM).

## Files not in the repo

| File | Why |
|---|---|
| `~/.gitconfig` | Holds your name and email. `install.sh` adds the LFS and delta settings to it |
| `~/.config/hypr/conf/monitors_local.lua` | Per-machine monitors, generated automatically (in `.gitignore`) |

## How to add things

- **An official package**: add it to the matching section of `pkglist.txt`. Comments with `#` are allowed.
- **An AUR package**: add it to `aurlist.txt`.
- **A program's config**: move its folder from `~/.config/` to `Configs/.config/` and run `Scripts/link.sh`, which creates the link in its place.
- **A system file**: put it in `Configs/etc/` with the same path it would have under `/etc`. `install.sh` copies it.
- **A VS Code extension**: install it and update the list with `code --list-extensions > vscode-extensions.txt`.
