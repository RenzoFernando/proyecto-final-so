$ScriptRoot = $PSScriptRoot

if ([string]::IsNullOrWhiteSpace($ScriptRoot)) {
    $ScriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
}

$ProjectScripts = @(
    "UI.ps1",
    "Users.ps1",
    "Storage.ps1",
    "Files.ps1",
    "Memory.ps1",
    "Backup.ps1"
)

foreach ($fileName in $ProjectScripts) {
    $scriptPath = Join-Path -Path $ScriptRoot -ChildPath "lib\$fileName"

    if (-not (Test-Path -LiteralPath $scriptPath)) {
        throw "No se encontró el archivo requerido: $scriptPath"
    }

    if (-not (Get-Item -LiteralPath $scriptPath -ErrorAction Stop).PSIsContainer) {
        . $scriptPath
    } else {
        throw "La ruta requerida no corresponde a un archivo: $scriptPath"
    }
}

function Require-ProjectFunction {
    param (
        [string]$FunctionName
    )

    if (-not (Get-Command $FunctionName -CommandType Function -ErrorAction SilentlyContinue)) {
        throw "No se cargó la función requerida: $FunctionName"
    }
}

Require-ProjectFunction "Show-MainMenu"
Require-ProjectFunction "Pause-Screen"
Require-ProjectFunction "Write-SectionTitle"
Require-ProjectFunction "Show-UsersLastLogin"
Require-ProjectFunction "Show-Filesystems"
Require-ProjectFunction "Show-TopTenFiles"
Require-ProjectFunction "Show-MemoryAndSwap"
Require-ProjectFunction "Start-Backup"

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
