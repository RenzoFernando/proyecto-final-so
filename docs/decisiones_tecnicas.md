# Decisiones técnicas

## Estructura

El proyecto se separó en dos herramientas: Bash para Linux y PowerShell para Windows. Cada herramienta tiene un archivo principal y módulos por opción del menú.

## Bash

La versión Bash usa comandos del sistema operativo: `/etc/passwd`, `lastlog`, `df`, `find`, `awk`, `/proc/meminfo`, `cp`, `stat`, `findmnt` y `lsblk`.

Para el backup se valida que el destino no sea el origen ni esté dentro de él. En Linux nativo se valida USB/removible con `lsblk`; en WSL se contempla el montaje de unidades Windows bajo `/mnt`.

## PowerShell

La versión PowerShell usa cmdlets y clases de Windows: `Get-LocalUser`, `net user`, `Get-CimInstance`, `Get-WmiObject`, `Win32_LogicalDisk`, `Win32_OperatingSystem` y `Win32_PageFileUsage`.

Para usuarios, si `Get-LocalUser` no entrega último login, se consulta una fuente auxiliar antes de mostrar el resultado.

## Documentación

Los scripts tienen documentación interna breve para explicar propósito, entradas y salidas principales.
