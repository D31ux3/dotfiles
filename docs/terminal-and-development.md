# Terminal and development

[← Back to README](../README.md)

## Shell: zsh

The shell is **zsh** with Oh My Zsh (`git` plugin) and the **starship** prompt. Config in `Configs/.zshrc`.

- **Autosuggestions**: as you type, the rest of the command appears in gray, taken from history. `→` accepts it and `Ctrl + →` accepts one word.
- **Syntax highlighting**: the command is colored as you type and turns red if it does not exist.
- **Editor**: `EDITOR` and `VISUAL` are `code --wait` in the graphical session, so Git commits, `sudoedit` or `Ctrl + X, Ctrl + E` open VS Code and wait until you close the tab. Without a graphical session (TTY, SSH), nano is used.

### Aliases and functions

| Command | What it does |
|---|---|
| `ls` | List with icons, folders first (eza) |
| `la` | Detailed list with hidden files and Git status |
| `ll` | Detailed list with Git status |
| `lt` | Two-level tree |
| `cat` | `bat`: shows files with syntax highlighting |
| `ff` | fastfetch (system info) |
| `gacp "message"` | `git add .` + commit with that message + push |
| `orphans` | Removes orphan packages (dependencies nothing uses anymore) |
| `dots` | Go to `~/dotfiles` |
| `reload` | Reload `.zshrc` |

### Terminal tools

| Tool | Usage |
|---|---|
| `fzf` | Interactive finder: `Ctrl + R` history, `Ctrl + T` files (with preview), `Alt + C` folders |
| `z <part of a path>` | Jumps to the most used matching folder (zoxide). `zi` picks it with fzf |
| `rg <text>` | Search text in files (ripgrep), respects `.gitignore` |
| `fd <name>` | Find files by name |
| `bat <file>` | View a file with colors and line numbers |
| `jq` | Read and filter JSON |
| `tldr <command>` | Practical examples of a command (tealdeer) |
| `btop`, `htop` | Process and resource monitors |
| `lazygit` | Git UI in the terminal |

## Git

- **delta** shows diffs with syntax highlighting and word-level changes. In a long diff, `n` / `N` jump between files.
- Conflicts use the `zdiff3` style, which also shows the original code.
- **Git LFS** is enabled for large files (textures, models, audio) in repos that set it up in `.gitattributes`.
- `~/.gitconfig` is not in the repo (it holds your identity); `install.sh` adds the settings above to it.
- **GitHub CLI** (`gh`) for PRs and issues from the terminal.

## Languages: mise

**mise** installs and switches each language's version per project (Node, Python, Rust, Go...). In a project folder:

```bash
mise use node@22      # installs Node 22 and pins it in mise.toml
mise use python@3.13
```

Entering the folder activates those versions automatically. mise also loads environment variables from the `[env]` section of `mise.toml`.

Also installed:

- **C/C++**: clang, lldb (debugger), cmake, ninja, meson, pkgconf, valgrind.
- **.NET**: `dotnet-sdk` (for Godot C# or Unity).

## Docker

Docker with `compose` and `buildx`. It does not start at boot: it starts the first time you run a `docker` command. Your user is in the `docker` group, so no `sudo` is needed.


## Virtual machines

**virt-manager** with QEMU/KVM through libvirt. libvirt starts the first time something connects to it (opening virt-manager), not at boot. Your user is in the `libvirt` group, so virt-manager manages the system VMs (`QEMU/KVM` connection) without asking for a password.

- **Network**: the VMs use libvirt's `default` NAT network (internet through the host), started automatically.
- **UEFI and TPM**: `edk2-ovmf` and `swtpm` are installed, so Windows 11 works: when creating the VM, tick *Customize configuration before install*, pick the `OVMF_CODE.secboot` firmware and add a TPM (emulated, version 2.0).
- **Docker and VMs at the same time**: by default Docker drops all forwarded traffic that is not its own, which leaves the VMs without internet while it runs. `Configs/etc/docker/daemon.json` sets `ip-forward-no-drop`, so it only adds its own rules and both work together.
## VS Code

- Runs as **native Wayland** (not blurry when scaled) and stores tokens in **gnome-keyring**. This is set by `ELECTRON_OZONE_PLATFORM_HINT` in `hypr/conf/env.lua` and by `Configs/.config/code-flags.conf`.
- **Settings**: `Configs/.config/Code/User/settings.json` is linked, so whatever you change in VS Code is saved in the repo.
- **Extensions**: `install.sh` installs the ones in `vscode-extensions.txt`. If you add or remove one, update the list:
  ```bash
  code --list-extensions > ~/dotfiles/vscode-extensions.txt
  ```

## Kitty (terminal)

Colors from the wallpaper (Tokyo Night as the fallback), semi-transparent background and the CaskaydiaCove Nerd Font. More themes are in `Configs/.config/kitty/themes/`; switch by changing the first `include` line in `kitty.conf`. The second one (`themes/matugen.conf`, written by matugen) overrides all of them with colors from the wallpaper, so remove it to keep a fixed theme.
