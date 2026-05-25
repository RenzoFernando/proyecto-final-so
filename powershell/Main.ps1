<#
.SYNOPSIS
Punto de entrada de la herramienta PowerShell del proyecto final.
.DESCRIPTION
Carga los módulos ubicados en la carpeta lib, valida que las funciones principales existan y ejecuta el menú de administración. El diseño separa el punto de entrada de las operaciones del sistema, de forma que cada opción de la rúbrica queda implementada en un archivo independiente.
.NOTES
Este script debe ejecutarse desde Windows PowerShell o PowerShell en Windows. Si la política de ejecución impide iniciar el archivo, puede usarse Set-ExecutionPolicy con alcance Process.
.EXAMPLE
.\Main.ps1
Ejecuta la aplicación desde la carpeta powershell.
#>

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
    <#
    .SYNOPSIS
    Verifica que una función requerida por el menú haya sido cargada.
    .DESCRIPTION
    Consulta el espacio de comandos de PowerShell con Get-Command. Si una función no existe, se detiene la ejecución antes de mostrar el menú, evitando fallas posteriores por módulos incompletos.
    .PARAMETER FunctionName
    Nombre exacto de la función que debe estar disponible.
    .OUTPUTS
    No genera objetos de salida cuando la función existe. Lanza una excepción si la función no fue cargada.
    .EXAMPLE
    Require-ProjectFunction "Show-MainMenu"
    Valida que la función del menú principal esté disponible.
    #>
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
    <#
    .SYNOPSIS
    Ejecuta el ciclo principal de la aplicación.
    .DESCRIPTION
    Presenta el menú, lee la opción digitada por el usuario y llama la función asociada. La instrucción switch implementa la selección múltiple de las cinco opciones exigidas en el proyecto.
    .OUTPUTS
    Escribe resultados en consola según la opción ejecutada.
    .EXAMPLE
    Start-App
    Inicia el menú interactivo de la herramienta.
    #>
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
