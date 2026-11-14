# Installation

[← Back to README](../README.md)

## Requirements

- Arch Linux with the base install done (a user with `sudo` and an internet connection).
- No desktop needs to be installed: the script installs Hyprland and the login screen (SDDM). If another display manager was already enabled (GDM, LightDM...), it disables it.

```bash
sudo pacman -S --needed git base-devel
git clone https://github.com/d31ux3/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

The repo works from any folder, but the `dots` zsh alias expects it at `~/dotfiles`.

## What `install.sh` does, in order

1. **Enables the multilib repository** in `/etc/pacman.conf` (32-bit packages, needed by Steam and Wine).
2. **Updates the system** (`pacman -Syu`).
3. **Installs yay**, the AUR helper, if it is missing.
4. **Installs the GPU drivers** with `Scripts/gpu-drivers.sh`, based on what `lspci` finds:
   - Intel and AMD: Vulkan (32-bit too) and video acceleration.
   - NVIDIA: picks the driver branch from the chip generation (Turing or newer → `nvidia-open`; Maxwell, Pascal, Volta → `580xx`; Kepler → `470xx`; older ones stay on nouveau). Uses the `-dkms` version and its headers when there is more than one kernel.
   - Hybrid laptop (Intel/AMD + NVIDIA): adds `nvidia-prime` to use `prime-run`.
5. **Installs the official packages** from `pkglist.txt`, then the AUR ones from `aurlist.txt`. It first tries the whole list at once (fast); if something fails, it retries package by package so one broken package does not block the rest.
6. **Installs the headers of every kernel**, needed by the `xpadneo-dkms` controller driver.
7. **Installs Oh My Zsh**.
8. **Links the configs** with `Scripts/link.sh` (see [Repo structure](structure.md)).
9. **Installs the VS Code extensions** from `vscode-extensions.txt`.
10. **Small tweaks**: dark theme in Dolphin, Dolphin for folders and satty for images (default apps), Git with LFS and delta.
11. **Copies the system files** from `Configs/etc/` to `/etc` (zram, Docker, the SDDM theme and its preset hook), **sets the profile picture** from `Assets/Pictures/pfp/` (`Scripts/avatar.sh`) and **sets up dual boot**: with systemd-boot, if Windows is on another disk, `Scripts/windows-boot.sh` copies its boot files to `/boot` so it shows up in the systemd-boot menu.
12. **Enables the services**: SDDM, NetworkManager, Bluetooth, power profiles, weekly SSD TRIM, weekly pacman cache cleanup, Docker and libvirt (both start on first use), and the NAT network for virtual machines.
13. **Adds the user to the groups** `docker`, `libvirt` and `gamemode`.
14. **Prints a summary** of the packages that could not be installed, if any.

The script is safe to run again: whatever is already installed or linked is skipped.

## After installing: manual steps

1. **Reboot.** The groups (`docker`, `libvirt`, `gamemode`), zram and the drivers apply on the next login.
2. **Git identity.** `~/.gitconfig` is not in the repo because it holds your name and email:
   ```bash
   git config --global user.name "Your name"
   git config --global user.email "you@example.com"
   ```
3. **GitHub CLI**: `gh auth login`. Credentials are stored in gnome-keyring.
4. **External monitors**: detected automatically the first time you plug them in and saved to `~/.config/hypr/conf/monitors_local.lua`. Adjust position, resolution or scale there (see [Desktop](desktop.md#monitors)).
5. **Steam games**: set each game's launch options (see [Gaming](gaming.md#launching-a-game)).
6. **Proton-GE**: open ProtonUp-Qt and install the latest version.
7. **Windows (dual boot)**: if Windows is missing from the boot menu, or stops booting after a large Windows update, run `~/dotfiles/Scripts/windows-boot.sh` (asks for the password) to copy its boot files to `/boot` again.

## If something fails

- **Packages that were not installed**: listed at the end of the script output. Usually they were renamed or dropped; fix the name in `pkglist.txt` or `aurlist.txt` and run `install.sh` again.
- **Hyprland config errors**: `hyprctl configerrors` shows them with the file and line.
