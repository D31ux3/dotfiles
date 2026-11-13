# Instalación

[← Volver al README](../README.md)

## Requisitos

- Arch Linux con la instalación base hecha (usuario con `sudo` y conexión a internet).
- No hace falta tener un escritorio instalado: el script instala Hyprland y la pantalla de inicio de sesión (SDDM). Si ya había otro gestor de inicio (GDM, LightDM...), lo desactiva.

```bash
sudo pacman -S --needed git base-devel
git clone https://github.com/d31ux3/dotfiles.git ~/dotfiles
~/dotfiles/install.sh
```

El repo funciona desde cualquier carpeta, pero el alias `dots` de zsh espera que esté en `~/dotfiles`.

## Qué hace `install.sh`, en orden

1. **Activa el repositorio multilib** en `/etc/pacman.conf` (paquetes de 32 bits, necesarios para Steam y Wine).
2. **Actualiza el sistema** (`pacman -Syu`).
3. **Instala yay**, el ayudante para paquetes de AUR, si no está.
4. **Instala los drivers de la GPU** con `Scripts/gpu-drivers.sh`, según lo que detecta `lspci`:
   - Intel y AMD: Vulkan (también de 32 bits) y aceleración de vídeo.
   - NVIDIA: elige la rama del driver por la generación del chip (Turing o posterior → `nvidia-open`; Maxwell, Pascal, Volta → `580xx`; Kepler → `470xx`; más antiguas se quedan con nouveau). Usa la versión `-dkms` y sus headers si hay más de un kernel.
   - Portátil híbrido (Intel/AMD + NVIDIA): añade `nvidia-prime` para usar `prime-run`.
5. **Instala los paquetes oficiales** de `pkglist.txt` y después los de AUR de `aurlist.txt`. Primero intenta toda la lista de una vez (rápido); si algo falla, reintenta paquete por paquete para que un paquete roto no bloquee al resto.
6. **Instala los headers de cada kernel**, que necesita el driver de mandos `xpadneo-dkms`.
7. **Instala Oh My Zsh**.
8. **Enlaza las configuraciones** con `Scripts/link.sh` (ver [Estructura del repo](estructura.md)).
9. **Instala las extensiones de VS Code** de `vscode-extensions.txt`.
10. **Ajustes sueltos**: tema oscuro en Dolphin, satty como visor de imágenes, Git con LFS y delta.
11. **Copia los archivos de sistema** de `Configs/etc/` a `/etc` (por ahora, zram).
12. **Activa los servicios**: SDDM, NetworkManager, Bluetooth, perfiles de energía, TRIM semanal del SSD, limpieza semanal de la caché de pacman y Docker (arranca al usarlo).
13. **Añade el usuario a los grupos** `docker` y `gamemode`.
14. **Muestra un resumen** con los paquetes que no se pudieron instalar, si hubo alguno.

El script se puede volver a ejecutar sin problema: lo que ya está instalado o enlazado se salta.

## Después de instalar: pasos manuales

1. **Reinicia.** Los grupos (`docker`, `gamemode`), zram y los drivers se aplican al iniciar sesión de nuevo.
2. **Identidad de Git.** `~/.gitconfig` no está en el repo porque contiene tu nombre y correo:
   ```bash
   git config --global user.name "Tu nombre"
   git config --global user.email "tu@correo.com"
   ```
3. **GitHub CLI**: `gh auth login`. Las credenciales se guardan en gnome-keyring.
4. **Monitores externos**: se detectan solos la primera vez que los conectas y se guardan en `~/.config/hypr/conf/monitors_local.lua`. Ajusta ahí la posición, la resolución o la escala (ver [Escritorio](escritorio.md#monitores)).
5. **Juegos de Steam**: en las opciones de lanzamiento de cada juego (ver [Juegos](juegos.md#lanzar-un-juego)).
6. **Proton-GE**: ábrelo con ProtonUp-Qt e instala la última versión.

## Si algo falla

- **Paquetes que no se instalaron**: aparecen al final de la salida del script. Lo habitual es que se hayan renombrado o retirado; corrige el nombre en `pkglist.txt` o `aurlist.txt` y vuelve a ejecutar `install.sh`.
- **Errores de configuración de Hyprland**: `hyprctl configerrors` los muestra con el archivo y la línea.
