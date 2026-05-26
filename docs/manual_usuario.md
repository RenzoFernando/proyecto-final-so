# Manual de usuario

## Objetivo

El proyecto contiene dos herramientas de consola para tareas básicas de administración: una en Bash para Linux y otra en PowerShell para Windows.

## Requisitos generales

- Para Bash: Linux, WSL o una distribución GNU/Linux con Bash.
- Para PowerShell: Windows PowerShell 5.1 o PowerShell 7 en Windows.
- Para backup: una memoria USB o unidad removible conectada.

## Ejecutar Bash

Desde la raíz del proyecto:

```bash
chmod +x bash/main.sh
./bash/main.sh
```

Desde la carpeta `bash`:

```bash
cd bash
chmod +x main.sh
./main.sh
```

En WSL, las unidades de Windows suelen verse así:

```text
/mnt/c
/mnt/d
/mnt/e
```

## Ejecutar PowerShell

Desde la raíz del proyecto:

```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\powershell\Main.ps1
```

Desde la carpeta `powershell`:

```powershell
cd powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\Main.ps1
```

## Menú principal

Las dos herramientas presentan las mismas opciones:

1. **Usuarios creados y último login**: muestra usuarios locales y último ingreso conocido.
2. **Filesystems/discos conectados**: muestra tamaño total y espacio libre en bytes.
3. **Diez archivos más grandes**: solicita una ruta y muestra los archivos de mayor tamaño.
4. **Memoria libre y swap/pagefile en uso**: muestra bytes y porcentaje.
5. **Backup de directorio a USB con catálogo**: copia un directorio y genera `catalogo_backup.csv`.
0. **Salir**: cierra la aplicación.

## Uso de rutas

Ejemplos válidos en PowerShell:

```text
C:\Users\usuario\Documents
E:\
```

Ejemplos válidos en Bash/Linux:

```text
/home/usuario/documentos
/media/usuario/USB
```

Ejemplos válidos en WSL:

```text
/mnt/c/Users/usuario/Documents
/mnt/e
```

## Backup

Antes de usar la opción 5, conecte la USB y confirme que el sistema la reconoce.

La herramienta solicita:

```text
Directorio origen
Directorio destino en la USB
```

El resultado se guarda con este formato:

```text
backup_nombreDirectorio_YYYYMMDD_HHMMSS
```

Dentro del backup se genera:

```text
catalogo_backup.csv
```

El catálogo contiene la ruta relativa de cada archivo copiado y su fecha de última modificación.

## Recomendación de prueba

Para probar sin afectar archivos importantes, cree una carpeta pequeña con dos o tres archivos y úsela como origen del backup.
