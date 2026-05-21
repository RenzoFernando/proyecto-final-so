function Show-TopTenFiles {
    Write-SectionTitle "Diez archivos más grandes"

    $inputPath = Read-Host "Digite el disco, filesystem o directorio a consultar"

    if ([string]::IsNullOrWhiteSpace($inputPath)) {
        Write-Host "Debe digitar una ruta."
        return
    }

    try {
        $resolvedPath = (Resolve-Path -LiteralPath $inputPath -ErrorAction Stop).ProviderPath
        $item = Get-Item -LiteralPath $resolvedPath -ErrorAction Stop

        if (-not $item.PSIsContainer) {
            Write-Host "La ruta especificada no es un directorio o filesystem válido."
            return
        }
    } catch {
        Write-Host "La ruta especificada no existe o no se puede consultar."
        return
    }

    $accessErrors = @()

    try {
        $files = @(Get-ChildItem -LiteralPath $resolvedPath -Recurse -File -Force -ErrorAction SilentlyContinue -ErrorVariable accessErrors |
            Sort-Object -Property Length -Descending |
            Select-Object -First 10 -Property @{
                Name = "TamanoBytes"
                Expression = { [int64]$_.Length }
            }, @{
                Name = "TrayectoriaCompleta"
                Expression = { $_.FullName }
            })

        if ($files.Count -eq 0) {
            Write-Host "No se encontraron archivos en la ruta especificada."
            return
        }

        $files | Format-Table -AutoSize -Wrap

        if ($accessErrors.Count -gt 0) {
            Write-Host ""
            Write-Host "Algunos archivos o directorios no se pudieron leer por permisos."
        }
    } catch {
        Write-Host "No se pudo completar la búsqueda de archivos."
        Write-Host $_
    }
}
