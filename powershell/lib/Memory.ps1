function Get-SystemMemoryInfo {
    try {
        if (Get-Command Get-CimInstance -ErrorAction SilentlyContinue) {
            $os = Get-CimInstance -ClassName Win32_OperatingSystem -ErrorAction Stop
            $pageFiles = Get-CimInstance -ClassName Win32_PageFileUsage -ErrorAction SilentlyContinue
        } else {
            $os = Get-WmiObject -Class Win32_OperatingSystem -ErrorAction Stop
            $pageFiles = Get-WmiObject -Class Win32_PageFileUsage -ErrorAction SilentlyContinue
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

        foreach ($pageFile in @($pageFiles)) {
            if ($null -ne $pageFile.AllocatedBaseSize) {
                $pageFileTotalBytes += [int64]$pageFile.AllocatedBaseSize * 1MB
            }

            if ($null -ne $pageFile.CurrentUsage) {
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
    Write-SectionTitle "Memoria libre y swap/pagefile en uso"

    try {
        Get-SystemMemoryInfo | Format-Table -AutoSize
    } catch {
        Write-Host $_
    }
}
