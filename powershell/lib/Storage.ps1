<#
.SYNOPSIS
Consulta discos/filesystems conectados en Windows.
.DESCRIPTION
Implementa la opción 2 del proyecto. Usa la clase Win32_LogicalDisk mediante CIM o WMI para consultar unidades lógicas, tipo, tamaño total y espacio libre en bytes.
#>

function Get-DriveTypeName {
    <#
    .SYNOPSIS
    Traduce el código DriveType de Windows a texto legible.
    .DESCRIPTION
    Win32_LogicalDisk representa el tipo de unidad con números. Esta función convierte esos números en etiquetas entendibles para el usuario.
    .PARAMETER DriveType
    Código numérico DriveType devuelto por Win32_LogicalDisk.
    .OUTPUTS
    Cadena con el nombre del tipo de disco.
    .EXAMPLE
    Get-DriveTypeName -DriveType 3
    Devuelve "Disco fijo".
    #>
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
    <#
    .SYNOPSIS
    Muestra discos conectados con tamaño y espacio libre en bytes.
    .DESCRIPTION
    Consulta Win32_LogicalDisk con Get-CimInstance si está disponible. Si CIM no está disponible, usa Get-WmiObject. La salida se ordena por letra de unidad y se presenta como tabla.
    .OUTPUTS
    Tabla escrita en consola con Disco, Etiqueta, Tipo, TamanoBytes y LibreBytes.
    .EXAMPLE
    Show-Filesystems
    Muestra la opción 2 del proyecto.
    #>
    Write-SectionTitle "Filesystems/discos conectados"

    try {
        if (Get-Command Get-CimInstance -ErrorAction SilentlyContinue) {
            $disks = @(Get-CimInstance -ClassName Win32_LogicalDisk -ErrorAction Stop)
        } else {
            $disks = @(Get-WmiObject -Class Win32_LogicalDisk -ErrorAction Stop)
        }

        $result = @($disks |
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
            })

        if ($result.Count -gt 0) {
            $result | Format-Table -AutoSize
        } else {
            Write-Host "No se encontraron discos con tamaño disponible."
        }
    } catch {
        Write-Host "No se pudieron consultar los discos conectados."
        Write-Host $_
    }
}
