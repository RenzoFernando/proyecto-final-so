<#
.SYNOPSIS
Consulta memoria física libre y pagefile/swap usado.
.DESCRIPTION
Implementa la opción 4 del proyecto. En Windows, la información de memoria física se obtiene desde Win32_OperatingSystem y el espacio de paginación usado desde Win32_PageFileUsage. El pagefile se reporta como equivalente práctico del swap.
#>

function Get-SystemMemoryInfo {
    <#
    .SYNOPSIS
    Devuelve objetos con memoria libre y pagefile/swap usado.
    .DESCRIPTION
    Usa CIM cuando está disponible y WMI como alternativa. Calcula bytes y porcentaje de memoria física libre y pagefile usado.
    .OUTPUTS
    Objetos PSCustomObject con Recurso, Bytes y Porcentaje.
    .EXAMPLE
    Get-SystemMemoryInfo
    Devuelve dos registros: memoria libre y pagefile/swap usado.
    #>
    try {
        if (Get-Command Get-CimInstance -ErrorAction SilentlyContinue) {
            $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
            $pageFiles = @(Get-CimInstance -ClassName Win32_PageFileUsage -ErrorAction SilentlyContinue)
        } else {
            $os = Get-WmiObject -Class Win32_OperatingSystem -ErrorAction Stop
            $pageFiles = @(Get-WmiObject -Class Win32_PageFileUsage -ErrorAction SilentlyContinue)
        }

        $memoryTotalBytes = [int64]$os.TotalVisibleMemorySize * 1KB
        $memoryFreeBytes = [int64]$os.FreePhysicalMemory * 1KB
        $memoryFreePercent = 0

        if ($memoryTotalBytes -gt 0) {
            $memoryFreePercent = [math]::Round(($memoryFreeBytes * 100) / $memoryTotalBytes, 2)
        }

        $pageFileTotalBytes = 0
        $pageFileUsedBytes = 0
        $pageFileUsedPercent = 0

        foreach ($pageFile in $pageFiles) {
            if ($null -ne $pageFile -and $null -ne $pageFile.AllocatedBaseSize) {
                $pageFileTotalBytes += [int64]$pageFile.AllocatedBaseSize * 1MB
            }

            if ($null -ne $pageFile -and $null -ne $pageFile.CurrentUsage) {
                $pageFileUsedBytes += [int64]$pageFile.CurrentUsage * 1MB
            }
        }

        if ($pageFileTotalBytes -gt 0) {
            $pageFileUsedPercent = [math]::Round(($pageFileUsedBytes * 100) / $pageFileTotalBytes, 2)
        }

        [PSCustomObject]@{
            Recurso = "Memoria libre"
            Bytes = $memoryFreeBytes
            Porcentaje = "$memoryFreePercent%"
        }

        [PSCustomObject]@{
            Recurso = "Pagefile/swap usado"
            Bytes = $pageFileUsedBytes
            Porcentaje = "$pageFileUsedPercent%"
        }
    } catch {
        throw "No se pudo obtener la información de memoria y pagefile."
    }
}

function Show-MemoryAndSwap {
    <#
    .SYNOPSIS
    Muestra memoria libre y pagefile/swap usado en formato de tabla.
    .DESCRIPTION
    Es la función llamada desde el menú para la opción 4. Encapsula la consulta y presentación para que los errores no cierren la aplicación.
    .OUTPUTS
    Tabla escrita en consola.
    .EXAMPLE
    Show-MemoryAndSwap
    Muestra la opción 4 del proyecto.
    #>
    Write-SectionTitle "Memoria libre y swap/pagefile en uso"

    try {
        Get-SystemMemoryInfo | Format-Table -AutoSize
    } catch {
        Write-Host $_
    }
}
