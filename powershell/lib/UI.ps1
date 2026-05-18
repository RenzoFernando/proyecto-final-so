function Show-MainMenu {
    Clear-Host
    Write-Host "=============================================="
    Write-Host " Herramienta PowerShell - Administración Data Center"
    Write-Host "=============================================="
    Write-Host "1. Usuarios creados y último login"
    Write-Host "2. Filesystems/discos conectados"
    Write-Host "3. Diez archivos más grandes"
    Write-Host "4. Memoria libre y swap/pagefile en uso"
    Write-Host "5. Backup de directorio a USB con catálogo"
    Write-Host "0. Salir"
    Write-Host "=============================================="
}

function Pause-Screen {
    Write-Host ""
    Read-Host "Presione ENTER para continuar"
}

function Write-SectionTitle {
    param (
        [string]$Title
    )

    Write-Host ""
    Write-Host "----------------------------------------------"
    Write-Host $Title
    Write-Host "----------------------------------------------"
}
