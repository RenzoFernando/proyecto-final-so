$ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path

function Import-ProjectScript {
    param (
        [string]$Path
    )

    if (Test-Path -LiteralPath $Path) {
        . $Path
    }
}

Import-ProjectScript "$ScriptRoot\lib\UI.ps1"
Import-ProjectScript "$ScriptRoot\lib\Users.ps1"
Import-ProjectScript "$ScriptRoot\lib\Storage.ps1"
Import-ProjectScript "$ScriptRoot\lib\Files.ps1"
Import-ProjectScript "$ScriptRoot\lib\Memory.ps1"
Import-ProjectScript "$ScriptRoot\lib\Backup.ps1"

if (-not (Get-Command Show-Filesystems -CommandType Function -ErrorAction SilentlyContinue)) {
    function Show-Filesystems {
        Write-SectionTitle "Filesystems/discos conectados"
        Write-Host "Funcionalidad pendiente por implementar por Luna."
    }
}

if (-not (Get-Command Show-TopTenFiles -CommandType Function -ErrorAction SilentlyContinue)) {
    function Show-TopTenFiles {
        Write-SectionTitle "Diez archivos más grandes"
        Write-Host "Funcionalidad pendiente por implementar por Luna."
    }
}

if (-not (Get-Command Show-MemoryAndSwap -CommandType Function -ErrorAction SilentlyContinue)) {
    function Show-MemoryAndSwap {
        Write-SectionTitle "Memoria libre y swap/pagefile en uso"
        Write-Host "Funcionalidad pendiente por implementar por Hideki."
    }
}

if (-not (Get-Command Start-Backup -CommandType Function -ErrorAction SilentlyContinue)) {
    function Start-Backup {
        Write-SectionTitle "Backup de directorio a USB con catálogo"
        Write-Host "Funcionalidad pendiente por implementar por Hideki."
    }
}

function Start-App {
    do {
        Show-MainMenu
        $option = Read-Host "Seleccione una opción"

        switch ($option) {
            "1" {
                Show-UsersLastLogin
                Pause-Screen
            }
            "2" {
                Show-Filesystems
                Pause-Screen
            }
            "3" {
                Show-TopTenFiles
                Pause-Screen
            }
            "4" {
                Show-MemoryAndSwap
                Pause-Screen
            }
            "5" {
                Start-Backup
                Pause-Screen
            }
            "0" {
                Write-Host "Saliendo..."
            }
            Default {
                Write-Host "Opción inválida."
                Pause-Screen
            }
        }
    } while ($option -ne "0")
}

Start-App
