# Escritorio

[← Volver al README](../README.md)

El escritorio es **Hyprland**, un gestor de ventanas en mosaico para Wayland. Su configuración está escrita en Lua y repartida en `Configs/.config/hypr/conf/`, un archivo por tema:

| Archivo | Contenido |
|---|---|
| `vars.lua` | Programas por defecto (terminal, navegador, explorador, lanzador) y la tecla `Super` |
| `monitors.lua` | Reglas generales de monitores |
| `env.lua` | Variables de entorno (cursor, tema Qt, apps Electron en Wayland) |
| `autostart.lua` | Lo que arranca al iniciar sesión |
| `look.lua` | Bordes, huecos, transparencias, desenfoque, animaciones, tearing y VRR |
| `input.lua` | Teclado, ratón y touchpad |
| `keybinds.lua` | Atajos de teclado (ver [Atajos](atajos.md)) |
| `rules.lua` | Reglas por ventana (flotantes, juegos, inactividad) |

Si una configuración tiene errores, `hyprctl configerrors` indica el archivo y la línea. Hyprland recarga los cambios solo al guardar.

## Inicio de sesión

**SDDM** es la pantalla de inicio de sesión y arranca Hyprland por defecto. Al entrar desbloquea **gnome-keyring**, donde VS Code, `gh`, el navegador y Discord guardan sus contraseñas y tokens.

Al arrancar Hyprland se inicia también: waybar, las notificaciones (swaync), hypridle, el montaje automático de USB, el fondo de pantalla, el agente de contraseñas (polkit), el historial del portapapeles y la detección de monitores.

## Waybar (barra superior)

| Zona | Módulo | Uso |
|---|---|---|
| Izquierda | CPU y memoria | El tooltip de memoria muestra también el swap (zram) |
| Izquierda | Reloj | Clic: fecha completa. Tooltip: calendario (rueda para cambiar de mes, clic derecho para ver el año) |
| Centro | Escritorios | Clic para ir a uno, rueda para pasar al siguiente |
| Derecha | Bandeja | Iconos de las apps en segundo plano |
| Derecha | Volumen | Clic: mezclador (pavucontrol). Clic derecho: silenciar. Rueda: volumen |
| Derecha | Red | Clic: menú de red (ver abajo) |
| Derecha | Batería | Cambia de color al bajar del 30 % (aviso) y del 15 % (crítico) |
| Derecha | Perfil de energía | Clic: alterna entre ahorro, equilibrado y rendimiento |
| Derecha | Notificaciones | Clic: panel de notificaciones. Clic derecho: no molestar |
| Derecha | ⏻ | Menú de apagado |

`Super + R` reinicia la barra. Su configuración está en `Configs/.config/waybar/`.

### Menú de red

Un menú de rofi (`waybar/scripts/network-menu.sh`) que usa NetworkManager: activar o desactivar el Wi-Fi, ver las redes con su intensidad y si tienen contraseña, conectarse (pide la contraseña si hace falta) y abrir la configuración avanzada. Si el menú ya está abierto, otro clic lo cierra.

## Inactividad, bloqueo y suspensión

Lo gestiona **hypridle** (`Configs/.config/hypr/hypridle.conf`):

- **Solo con batería**: a los 5 minutos baja el brillo al mínimo y a los 10 suspende. Con el cargador conectado, o en un PC de sobremesa, no hace nada.
- **No actúa** mientras suena audio (música, llamadas, juegos), mientras haya una ventana en pantalla completa (vídeos, presentaciones) ni mientras un juego tenga el foco. Así un mando, que no cuenta como actividad, no deja que se suspenda en mitad de una partida.
- **Antes de suspender** bloquea la pantalla, así que al volver pide la contraseña.

La pantalla de bloqueo es **hyprlock** (`Super + L` o desde el menú de apagado).

## Monitores

- Cualquier monitor funciona al conectarlo: usa su resolución nativa, posición automática y escala 1.
- La primera vez que conectas un monitor, `scripts/detect-monitors.py` le escribe una regla en `~/.config/hypr/conf/monitors_local.lua` con su configuración actual y la lista de modos disponibles. Edita esa regla para cambiar la resolución, la frecuencia, la posición o la escala. Se identifica por marca, modelo y número de serie, así que la regla sigue a la pantalla aunque cambies de puerto.
- Ese archivo es de cada equipo y no está en el repo. Para que un monitor se vuelva a detectar, borra su bloque.
- El VRR (FreeSync/G-Sync) se activa solo en pantalla completa y en pantallas que lo soportan.

## Fondo de pantalla

Lo pone **awww** con `scripts/wallpaper.sh`. Los fondos están en `Assets/Pictures/Wallpapers/` (enlazado en `~/Pictures/Wallpapers`). La primera vez usa `Lucy-rain.png`; después awww recuerda el último que pusiste. Para cambiarlo:

```bash
awww img ~/Pictures/Wallpapers/Leva-simple.png
```

## Capturas de pantalla

- `Impr Pant`: seleccionas una región y se copia al portapapeles.
- `Super + Impr Pant`: captura toda la pantalla, la copia y la abre en **satty** para dibujar, recortar o señalar. Desde satty se puede guardar o volver a copiar.
- satty es también el visor de imágenes por defecto.

## Portapapeles

**cliphist** guarda el historial de todo lo que copias (texto e imágenes). `Super + V` lo abre en rofi; lo que eliges vuelve al portapapeles.

## Teclado y entrada

- Distribución **US internacional con AltGr**: teclado americano con los caracteres del español en `AltGr` (ver [Atajos](atajos.md#caracteres-en-español)).
- Ratón sin aceleración y gesto de tres dedos en el touchpad para cambiar de escritorio.

## Dispositivos

- **USB y discos externos**: udiskie los monta solo y muestra una notificación. Mientras haya uno conectado aparece un icono en la bandeja para abrirlo o expulsarlo. Lee NTFS y exFAT.
- **Bluetooth**: blueman, desde la bandeja.
- **Audio**: PipeWire. `pavucontrol` (clic en el volumen de waybar) para elegir salidas y entradas.
- **Energía**: power-profiles-daemon, desde waybar.

## Apariencia

- **Ventanas**: bordes con degradado cian-verde, esquinas redondeadas, transparencia (95 % la activa, 85 % las demás) y desenfoque. Los juegos y Steam siempre opacos.
- **Apps GTK**: tema `adw-gtk3-dark` y modo oscuro global (se cambia con `nwg-look`).
- **Apps Qt/KDE** (Dolphin, Ark): Breeze oscuro con `qt6ct`.
- **Terminal**: kitty con el tema Tokyo Night, fondo semitransparente y la fuente CaskaydiaCove Nerd Font.
- **Lanzador**: rofi con los temas de [adi1090x/rofi](https://github.com/adi1090x/rofi) (`Configs/.config/rofi/`). Se usa el estilo `type-7`.

## Aplicaciones por defecto

| Uso | Aplicación |
|---|---|
| Terminal | kitty |
| Navegador | Brave Origin (también está Firefox) |
| Archivos | Dolphin (con "Abrir terminal aquí" en kitty) |
| Comprimidos | Ark |
| Imágenes | satty |
| Vídeo | mpv |
| Grabar pantalla | OBS Studio |
| Editor | VS Code |

Se cambian en `Configs/.config/hypr/conf/vars.lua`.
