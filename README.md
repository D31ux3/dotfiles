# dotfiles

Entorno de escritorio completo sobre **Arch Linux + Hyprland**, pensado para desarrollar software, hacer videojuegos y jugar. Un solo script deja un sistema recién instalado listo para usar: paquetes, drivers, configuración y servicios.

## Qué incluye

- **Escritorio Hyprland** (configuración en Lua) con waybar, rofi, notificaciones, bloqueo y suspensión por inactividad, menú de apagado y detección automática de monitores.
- **Drivers de GPU automáticos**: detecta Intel, AMD y NVIDIA (incluidas las ramas antiguas y los portátiles híbridos) e instala lo que corresponde.
- **Terminal**: kitty + zsh con autosugerencias, resaltado de sintaxis, starship, fzf, zoxide, bat, eza y ripgrep.
- **Desarrollo**: C/C++ (clang, cmake, ninja), mise para versiones de lenguajes, .NET, Docker, Git con LFS y delta, y VS Code configurado para Wayland.
- **Juegos**: Steam, Lutris, Proton-GE, gamemode, MangoHud, gamescope, mandos de Xbox por Bluetooth, y Hyprland ajustado (tearing, VRR, sin transparencias ni bloqueos en mitad de una partida).
- **Arte y audio**: Krita y Audacity.

## Instalación rápida

Sobre una instalación base de Arch Linux:

```bash
sudo pacman -S --needed git base-devel
git clone https://github.com/d31ux3/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

Al terminar, reinicia. Los detalles y los pasos manuales están en [docs/instalacion.md](docs/instalacion.md).

## Documentación

| Documento | Contenido |
|---|---|
| [Instalación](docs/instalacion.md) | Qué hace `install.sh` paso a paso y lo que queda por hacer a mano |
| [Atajos de teclado](docs/atajos.md) | Todos los atajos de Hyprland y de la terminal |
| [Escritorio](docs/escritorio.md) | Waybar, menús, inactividad, monitores, capturas, portapapeles, teclado |
| [Terminal y desarrollo](docs/terminal-y-desarrollo.md) | zsh, alias, herramientas, Git, mise, Docker, VS Code |
| [Juegos](docs/juegos.md) | Herramientas, mandos, ajustes de Hyprland y cómo lanzar los juegos |
| [Estructura del repo](docs/estructura.md) | Cómo está organizado y cómo añadir paquetes o configuraciones |
