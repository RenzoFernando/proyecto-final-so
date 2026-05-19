function Get-DriveTypeName {
    param (
        [int]$DriveType
    )

    switch ($DriveType) {
        0 { "Desconocido" }
        1 { "Sin directorio raíz" }
        2 { "Removible" }
        3 { "Disco fijo" }
        4 { "Red" }
        5 { "CD-ROM" }
        6 { "RAM disk" }
        Default { "No identificado" }
    }
}

function Show-Filesystems {
    Write-SectionTitle "Filesystems/discos conectados"

    try {
        if (Get-Command Get-CimInstance -ErrorAction SilentlyContinue) {
            $disks = Get-CimInstance -ClassName Win32_LogicalDisk -ErrorAction Stop
        } else {
            $disks = Get-WmiObject -Class Win32_LogicalDisk -ErrorAction Stop
        }

        $result = $disks |
            Where-Object { $null -ne $_.Size } |
            Sort-Object -Property DeviceID |
            Select-Object -Property @{
                Name = "Disco"
                Expression = { $_.DeviceID }
            }, @{
                Name = "Etiqueta"
                Expression = {
                    if ($_.VolumeName) {
                        $_.VolumeName
                    } else {
                        "Sin etiqueta"
                    }
                }
            }, @{
                Name = "Tipo"
                Expression = { Get-DriveTypeName -DriveType $_.DriveType }
            }, @{
                Name = "TamanoBytes"
                Expression = { [int64]$_.Size }
            }, @{
                Name = "LibreBytes"
                Expression = { [int64]$_.FreeSpace }
            }

        if ($result) {
            $result | Format-Table -AutoSize
        } else {
            Write-Host "No se encontraron discos con tamaño disponible."
        }
    } catch {
        Write-Host "No se pudieron consultar los discos conectados."
        Write-Host $_
    }
}
