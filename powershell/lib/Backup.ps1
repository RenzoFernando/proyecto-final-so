<#
.SYNOPSIS
Realiza backup de un directorio hacia una memoria USB.
.DESCRIPTION
Implementa la opción 5 del proyecto. Valida origen, destino, permisos de escritura, evita copias recursivas, confirma que el destino corresponda a una unidad removible o USB y genera un catálogo CSV con rutas relativas y fechas de última modificación.
#>

function Test-WritableDirectory {
    <#
    .SYNOPSIS
    Comprueba si una ruta permite crear y eliminar archivos.
    .DESCRIPTION
    Crea un archivo temporal con nombre aleatorio dentro del destino y lo elimina. Si ambas operaciones son correctas, la ruta se considera escribible.
    .PARAMETER Path
    Directorio que se validará.
    .OUTPUTS
    Booleano: true si la ruta es escribible, false en caso contrario.
    .EXAMPLE
    Test-WritableDirectory -Path "E:\"
    Comprueba si la unidad E permite escritura.
    #>
    param (
        [string]$Path
    )

    try {
        $testFile = Join-Path -Path $Path -ChildPath ([System.IO.Path]::GetRandomFileName())
        New-Item -ItemType File -Path $testFile -Force -ErrorAction Stop | Out-Null
        Remove-Item -LiteralPath $testFile -Force -ErrorAction Stop
        return $true
    } catch {
        return $false
    }
}

function Test-DestinationInsideSource {
    <#
    .SYNOPSIS
    Determina si el destino es el origen o está dentro del origen.
    .DESCRIPTION
    Normaliza rutas con GetFullPath y compara con OrdinalIgnoreCase, adecuado para rutas de Windows. Evita que el backup copie dentro de sí mismo.
    .PARAMETER SourcePath
    Directorio origen del backup.
    .PARAMETER DestinationPath
    Directorio destino seleccionado por el usuario.
    .OUTPUTS
    Booleano: true si el destino no es válido por estar dentro del origen.
    .EXAMPLE
    Test-DestinationInsideSource -SourcePath "C:\Datos" -DestinationPath "C:\Datos\Backup"
    Devuelve true.
    #>
    param (
        [string]$SourcePath,
        [string]$DestinationPath
    )

    $trimCharacters = [char[]]@([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar)
    $sourceFull = [System.IO.Path]::GetFullPath($SourcePath).TrimEnd($trimCharacters)
    $destinationFull = [System.IO.Path]::GetFullPath($DestinationPath).TrimEnd($trimCharacters)
    $sourcePrefix = $sourceFull + [System.IO.Path]::DirectorySeparatorChar

    if ($destinationFull.Equals($sourceFull, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $true
    }

    if ($destinationFull.StartsWith($sourcePrefix, [System.StringComparison]::OrdinalIgnoreCase)) {
        return $true
    }

    return $false
}

function Test-UsbDestination {
    <#
    .SYNOPSIS
    Comprueba si el destino pertenece a una unidad removible o USB.
    .DESCRIPTION
    Primero obtiene la raíz de la unidad. Luego consulta Win32_LogicalDisk. Si DriveType es 2, se acepta como unidad removible. Si no, intenta asociar la unidad lógica con particiones y discos físicos para detectar InterfaceType USB o PNPDeviceID relacionado con USB.
    .PARAMETER DestinationPath
    Ruta destino del backup.
    .OUTPUTS
    Booleano: true si el destino corresponde a USB/removible.
    .EXAMPLE
    Test-UsbDestination -DestinationPath "E:\Backups"
    Valida si E: corresponde a una unidad removible o USB.
    #>
    param (
        [string]$DestinationPath
    )

    try {
        $driveRoot = [System.IO.Path]::GetPathRoot($DestinationPath)

        if ([string]::IsNullOrWhiteSpace($driveRoot)) {
            return $false
        }

        $driveId = $driveRoot.TrimEnd('\')

        if (Get-Command Get-CimInstance -ErrorAction SilentlyContinue) {
            $logicalDisk = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DeviceID='$driveId'" -ErrorAction Stop

            if ($logicalDisk.DriveType -eq 2) {
                return $true
            }

            if (Get-Command Get-CimAssociatedInstance -ErrorAction SilentlyContinue) {
                $partitions = @(Get-CimAssociatedInstance -InputObject $logicalDisk -Association Win32_LogicalDiskToPartition -ErrorAction SilentlyContinue)
                foreach ($partition in $partitions) {
                    $diskDrives = @(Get-CimAssociatedInstance -InputObject $partition -Association Win32_DiskDriveToDiskPartition -ErrorAction SilentlyContinue)
                    foreach ($diskDrive in $diskDrives) {
                        if ($diskDrive.InterfaceType -eq "USB" -or $diskDrive.PNPDeviceID -match "USB") {
                            return $true
                        }
                    }
                }
            }
        } else {
            $logicalDisk = Get-WmiObject -Class Win32_LogicalDisk -Filter "DeviceID='$driveId'" -ErrorAction Stop

            if ($logicalDisk.DriveType -eq 2) {
                return $true
            }
        }

        return $false
    } catch {
        return $false
    }
}

function New-BackupCatalog {
    <#
    .SYNOPSIS
    Genera el catálogo CSV del backup.
    .DESCRIPTION
    Recorre los archivos copiados, excluye el catálogo mismo y exporta ruta relativa y fecha de última modificación. Se usa Export-Csv para producir un archivo estructurado y fácil de abrir en herramientas de análisis.
    .PARAMETER BackupDirectory
    Directorio donde quedó la copia de seguridad.
    .PARAMETER CatalogPath
    Ruta completa del archivo CSV de catálogo.
    .OUTPUTS
    Crea un archivo CSV en disco.
    .EXAMPLE
    New-BackupCatalog -BackupDirectory "E:\backup_Datos_20260601_100000" -CatalogPath "E:\backup_Datos_20260601_100000\catalogo_backup.csv"
    Genera el catálogo del backup indicado.
    #>
    param (
        [string]$BackupDirectory,
        [string]$CatalogPath
    )

    $trimCharacters = [char[]]@('\', '/')
    $catalogEntries = @(Get-ChildItem -LiteralPath $BackupDirectory -Recurse -File -Force -ErrorAction SilentlyContinue |
        Where-Object { $_.FullName -ne $CatalogPath } |
        Sort-Object -Property FullName |
        Select-Object -Property @{
            Name = "Ruta"
            Expression = {
                $_.FullName.Substring($BackupDirectory.Length).TrimStart($trimCharacters)
            }
        }, @{
            Name = "UltimaModificacion"
            Expression = { $_.LastWriteTime }
        })

    if ($catalogEntries.Count -gt 0) {
        $catalogEntries | Export-Csv -LiteralPath $CatalogPath -NoTypeInformation -Encoding UTF8
    } else {
        '"Ruta","UltimaModificacion"' | Set-Content -LiteralPath $CatalogPath -Encoding UTF8
    }
}

function Start-Backup {
    <#
    .SYNOPSIS
    Ejecuta el backup y genera el catálogo de archivos copiados.
    .DESCRIPTION
    Solicita origen y destino. Valida entradas vacías, existencia, tipo directorio, permisos, rutas recursivas y destino USB/removible. Luego copia el contenido del origen y genera catalogo_backup.csv dentro del directorio de backup.
    .OUTPUTS
    Mensajes de estado en consola y archivos creados en la unidad destino.
    .EXAMPLE
    Start-Backup
    Inicia la opción interactiva de backup.
    #>
    Write-SectionTitle "Backup de directorio a USB con catálogo"

    $sourceInput = Read-Host "Digite el directorio origen"
    $destinationInput = Read-Host "Digite el directorio destino en la USB"

    if ([string]::IsNullOrWhiteSpace($sourceInput)) {
        Write-Host "Debe digitar el directorio origen."
        return
    }

    if ([string]::IsNullOrWhiteSpace($destinationInput)) {
        Write-Host "Debe digitar el directorio destino."
        return
    }

    try {
        $sourcePath = (Resolve-Path -LiteralPath $sourceInput -ErrorAction Stop).ProviderPath
        $sourceItem = Get-Item -LiteralPath $sourcePath -ErrorAction Stop

        if (-not $sourceItem.PSIsContainer) {
            Write-Host "El directorio origen no existe o no es un directorio."
            return
        }
    } catch {
        Write-Host "El directorio origen no existe o no se puede consultar."
        return
    }

    try {
        $destinationPath = (Resolve-Path -LiteralPath $destinationInput -ErrorAction Stop).ProviderPath
        $destinationItem = Get-Item -LiteralPath $destinationPath -ErrorAction Stop

        if (-not $destinationItem.PSIsContainer) {
            Write-Host "El destino no existe o no es un directorio."
            return
        }
    } catch {
        Write-Host "El destino no existe o no se puede consultar."
        return
    }

    if (Test-DestinationInsideSource -SourcePath $sourcePath -DestinationPath $destinationPath) {
        Write-Host "El destino no puede ser el mismo directorio origen ni estar dentro de él."
        return
    }

    if (-not (Test-WritableDirectory -Path $destinationPath)) {
        Write-Host "El destino no tiene permisos de escritura."
        return
    }

    if (-not (Test-UsbDestination -DestinationPath $destinationPath)) {
        Write-Host "El destino debe corresponder a una memoria USB o unidad removible."
        return
    }

    $sourceName = Split-Path -Path $sourcePath -Leaf

    if ([string]::IsNullOrWhiteSpace($sourceName)) {
        $sourceName = "directorio"
    }

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupDirectory = Join-Path -Path $destinationPath -ChildPath "backup_${sourceName}_$timestamp"
    $catalogPath = Join-Path -Path $backupDirectory -ChildPath "catalogo_backup.csv"

    try {
        New-Item -ItemType Directory -Path $backupDirectory -ErrorAction Stop | Out-Null

        Get-ChildItem -LiteralPath $sourcePath -Force -ErrorAction Stop | ForEach-Object {
            Copy-Item -LiteralPath $_.FullName -Destination $backupDirectory -Recurse -Force -ErrorAction Stop
        }

        New-BackupCatalog -BackupDirectory $backupDirectory -CatalogPath $catalogPath

        Write-Host "Backup finalizado correctamente."
        Write-Host "Directorio de backup: $backupDirectory"
        Write-Host "Catálogo: $catalogPath"
    } catch {
        Write-Host "No se pudo completar la copia de seguridad."
        Write-Host $_

        if (Test-Path -LiteralPath $backupDirectory) {
            Remove-Item -LiteralPath $backupDirectory -Recurse -Force -ErrorAction SilentlyContinue
        }
    }
}
