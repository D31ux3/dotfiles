# Gaming

[← Back to README](../README.md)

## Installed tools

| Tool | What it is for |
|---|---|
| **Steam** | Store and library. Windows games run through Proton |
| **ProtonUp-Qt** | Installs Proton-GE, a Proton build with extra patches (better compatibility, cutscene videos) |
| **Lutris** | Games outside Steam: GOG, Epic, Battle.net, emulators... |
| **Wine (staging) and winetricks** | Run Windows programs and add libraries to them |
| **gamemode** | Puts the CPU in performance mode and raises the game's priority while it runs |
| **MangoHud** | Overlay with FPS, temperatures and CPU/GPU usage. `Right Shift + F12` toggles it |
| **gamescope** | Runs the game inside its own compositor: FPS limits, resolution scaling (FSR) |

Vulkan drivers, including 32-bit ones, are installed by `install.sh` for your GPU.

## Launching a game

In Steam: right click the game → **Properties** → **Launch options**:

```
gamemoderun mangohud %command%
```

On a **laptop with an NVIDIA GPU plus an integrated one**, games use the integrated GPU unless told otherwise. Add `prime-run` in front:

```
prime-run gamemoderun mangohud %command%
```

For a Windows game, pick the Proton version in **Properties → Compatibility** (once Proton-GE is installed with ProtonUp-Qt, it shows up in that list).

## Controllers

- **Xbox over Bluetooth**: the `xpadneo` driver improves the connection, rumble and battery level reporting. Pair it from blueman (tray).
- **Other controllers** (PlayStation, Nintendo, 8BitDo...): `game-devices-udev` grants the permissions Steam and games need to detect them.

## Hyprland tweaks for games

In `hypr/conf/look.lua` and `hypr/conf/rules.lua`:

- **What counts as a game**: Steam game windows (`steam_app_<number>`), gamescope windows and windows that declare themselves a game.
- **Tearing allowed**: games are shown without waiting for vsync, for lower input latency.
- **Always opaque**: games, Steam and Godot ignore window transparency (tools launched from Steam keep their own window class, so they are listed one by one in `rules.lua`).
- **No lock or suspend**: while a game has focus or something is fullscreen (see [Desktop](desktop.md#idle-lock-and-suspend)).
- **VRR** (FreeSync / G-Sync): in fullscreen, if the monitor supports it.

## Checks

```bash
groups                 # should include gamemode (if not, log out and back in)
gamemoded -t           # gamemode self-test
prime-run vulkaninfo --summary | grep deviceName   # the NVIDIA GPU responds (needs vulkan-tools)
```
