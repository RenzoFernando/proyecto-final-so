# Herramienta Bash

Herramienta de administración para Linux orientada a tareas básicas de operación en un data center. La aplicación está escrita como un conjunto de scripts Bash separados por responsabilidad, siguiendo la idea de scripts interpretados con `#!/bin/bash`, funciones, variables locales, validaciones con expresiones condicionales y uso de comandos estándar del sistema operativo.

## Requisitos

- Sistema GNU/Linux con Bash.
- Permiso de ejecución sobre `bash/main.sh`.
- Comandos requeridos: `awk`, `cat`, `cp`, `date`, `df`, `find`, `head`, `mkdir`, `mktemp`, `rm`, `sed`, `sort`, `stat`.
- Para resolver trayectorias: `realpath` o, en su defecto, `cd` y `pwd`.
- Para último login: `lastlog` o `last`.
- Para validar que el destino del backup sea USB/removible: `findmnt` y `lsblk`.

## Ejecución

Desde la carpeta `bash`:

```bash
chmod +x main.sh
./main.sh
```

Desde la raíz del repositorio:

```bash
chmod +x bash/main.sh
./bash/main.sh
```

## Opciones del menú

1. **Usuarios creados y último login**: lista usuarios locales interactivos y muestra su último ingreso registrado.
2. **Filesystems/discos conectados**: consulta filesystems montados con tamaño total y espacio libre en bytes.
3. **Diez archivos más grandes**: pide una ruta, recorre sus archivos y muestra los diez de mayor tamaño con trayectoria completa.
4. **Memoria libre y swap en uso**: lee `/proc/meminfo` y calcula valores en bytes y porcentaje.
5. **Backup de directorio a USB con catálogo**: copia un directorio a una unidad removible y genera `catalogo_backup.csv` con ruta relativa y fecha de última modificación.

## Organización

```text
main.sh          Punto de entrada, carga de módulos y ciclo del menú.
lib/ui.sh        Presentación, títulos y pausas.
lib/users.sh     Opción 1: usuarios y último login.
lib/storage.sh   Opción 2: filesystems y espacio libre.
lib/files.sh     Opción 3: diez archivos más grandes.
lib/memory.sh    Opción 4: memoria y swap.
lib/backup.sh    Opción 5: backup y catálogo.
```

## Criterio de usuarios

La opción 1 toma como usuarios creados los usuarios locales interactivos: `root` y usuarios con UID igual o superior al UID mínimo configurado en `/etc/login.defs`. Se excluyen cuentas con shell `nologin` o `false`, porque normalmente corresponden a servicios del sistema.

## Criterio de memoria

Si `/proc/meminfo` contiene `MemAvailable`, se usa ese valor como mejor aproximación de memoria disponible. Si no existe, se usa `MemFree`.

## Criterio de backup a USB

El destino debe estar montado sobre una unidad removible o con transporte USB según `lsblk`. No se permite que el destino sea el mismo origen ni que esté dentro del origen, para evitar copias recursivas.
