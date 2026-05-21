function Test-WritableDirectory {
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

function Start-Backup {
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

        $trimCharacters = [char[]]@('\', '/')
        $catalogEntries = @(Get-ChildItem -LiteralPath $backupDirectory -Recurse -File -Force -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -ne $catalogPath } |
            Sort-Object -Property FullName |
            Select-Object -Property @{
                Name = "Ruta"
                Expression = {
                    $_.FullName.Substring($backupDirectory.Length).TrimStart($trimCharacters)
                }
            }, @{
                Name = "UltimaModificacion"
                Expression = { $_.LastWriteTime }
            })

        if ($catalogEntries.Count -gt 0) {
            $catalogEntries | Export-Csv -LiteralPath $catalogPath -NoTypeInformation -Encoding UTF8
        } else {
            '"Ruta","UltimaModificacion"' | Set-Content -LiteralPath $catalogPath -Encoding UTF8
        }

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
