# Herramienta PowerShell

Herramienta de administración para Windows orientada a tareas básicas de operación en un data center. La aplicación está escrita en PowerShell con módulos separados por responsabilidad y documentación interna en formato de ayuda comentada (`.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, `.OUTPUTS`, `.EXAMPLE`), de manera similar a la ayuda que puede consultarse con `Get-Help`.

## Requisitos

- Windows PowerShell 5.1 o PowerShell 7 ejecutándose en Windows.
- Permisos suficientes para consultar usuarios locales, discos, memoria y pagefile.
- Para backup: una memoria USB o unidad removible conectada y con permisos de escritura.
- Fuentes del sistema utilizadas: `Get-LocalUser`, `Get-CimInstance`, `Get-WmiObject`, clases `Win32_LogicalDisk`, `Win32_OperatingSystem`, `Win32_PageFileUsage`, `Win32_UserAccount`.

## Ejecución

Desde la carpeta `powershell`:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\Main.ps1
```

Desde la raíz del repositorio:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\powershell\Main.ps1
```

## Opciones del menú

1. **Usuarios creados y último login**: lista usuarios locales y muestra su último ingreso conocido.
2. **Filesystems/discos conectados**: consulta unidades lógicas con tamaño total y espacio libre en bytes.
3. **Diez archivos más grandes**: pide una ruta y muestra los diez archivos más grandes con trayectoria completa.
4. **Memoria libre y swap/pagefile en uso**: consulta memoria física libre y uso del archivo de paginación.
5. **Backup de directorio a USB con catálogo**: copia un directorio a una unidad removible y genera `catalogo_backup.csv` con ruta relativa y fecha de última modificación.

## Organización

```text
Main.ps1          Punto de entrada, carga de módulos y ciclo del menú.
lib/UI.ps1        Presentación, títulos y pausas.
lib/Users.ps1     Opción 1: usuarios y último login.
lib/Storage.ps1   Opción 2: discos y espacio libre.
lib/Files.ps1     Opción 3: diez archivos más grandes.
lib/Memory.ps1    Opción 4: memoria y pagefile.
lib/Backup.ps1    Opción 5: backup y catálogo.
```

## Criterio de swap en Windows

Windows no expone el swap de la misma forma que Linux. Para cumplir el objetivo administrativo de la rúbrica, la herramienta reporta el uso del pagefile mediante `Win32_PageFileUsage`, que es el equivalente práctico del espacio de paginación usado por el sistema.

## Criterio de backup a USB

El destino debe estar ubicado en una unidad removible (`DriveType = 2`) o en una unidad asociada a un dispositivo USB mediante CIM. Si se selecciona una carpeta en el disco interno, la aplicación debe rechazarla.
