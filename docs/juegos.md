# Juegos

[← Volver al README](../README.md)

## Herramientas instaladas

| Herramienta | Para qué sirve |
|---|---|
| **Steam** | Tienda y biblioteca. Los juegos de Windows funcionan con Proton |
| **ProtonUp-Qt** | Instala Proton-GE, una versión de Proton con más parches (mejor compatibilidad, vídeos de cinemáticas) |
| **Lutris** | Juegos fuera de Steam: GOG, Epic, Battle.net, emuladores... |
| **Wine (staging) y winetricks** | Ejecutar programas de Windows y añadirles librerías |
| **gamemode** | Pone la CPU en modo rendimiento y sube la prioridad del juego mientras está abierto |
| **MangoHud** | Overlay con FPS, temperaturas y uso de CPU/GPU. `Shift derecho + F12` lo muestra u oculta |
| **gamescope** | Ejecuta el juego en su propia ventana-compositor: limitar FPS, escalar resolución (FSR) |

Los drivers de Vulkan, incluidos los de 32 bits, los instala `install.sh` según tu GPU.

## Lanzar un juego

En Steam: clic derecho en el juego → **Propiedades** → **Opciones de lanzamiento**:

```
gamemoderun mangohud %command%
```

En un **portátil con gráfica NVIDIA y otra integrada**, el juego usa la integrada si no se le indica lo contrario. Añade `prime-run` delante:

```
prime-run gamemoderun mangohud %command%
```

Para un juego de Windows, elige la versión de Proton en **Propiedades → Compatibilidad** (después de instalar Proton-GE con ProtonUp-Qt, aparece en esa lista).

## Mandos

- **Xbox por Bluetooth**: el driver `xpadneo` mejora la conexión, la vibración y el nivel de batería. Se empareja desde blueman (bandeja).
- **Otros mandos** (PlayStation, Nintendo, 8BitDo...): `game-devices-udev` da los permisos necesarios para que Steam y los juegos los reconozcan.

## Ajustes de Hyprland para juegos

En `hypr/conf/look.lua` y `hypr/conf/rules.lua`:

- **Qué cuenta como juego**: las ventanas de Steam (`steam_app_<número>`), las de gamescope y las que se declaran como juego.
- **Tearing permitido**: los juegos se muestran sin esperar a la sincronización vertical, con menos retraso de entrada.
- **Siempre opacos**: los juegos y Steam ignoran la transparencia de las ventanas.
- **Sin bloqueo ni suspensión**: mientras un juego tiene el foco o algo está en pantalla completa (ver [Escritorio](escritorio.md#inactividad-bloqueo-y-suspensión)).
- **VRR** (FreeSync / G-Sync): en pantalla completa, si el monitor lo soporta.

## Comprobaciones

```bash
groups                 # debe incluir gamemode (si no, cierra sesión y vuelve a entrar)
gamemoded -t           # prueba de gamemode
prime-run vulkaninfo --summary | grep deviceName   # la GPU NVIDIA responde (requiere vulkan-tools)
```
