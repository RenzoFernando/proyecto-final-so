<#
.SYNOPSIS
Funciones de interfaz de consola para la herramienta PowerShell.
.DESCRIPTION
Centraliza el menú principal, las pausas y los títulos de sección. Esta separación evita repetir salida visual en los módulos funcionales y permite mantener una presentación uniforme durante la sustentación.
#>

function Show-MainMenu {
    <#
    .SYNOPSIS
    Muestra las opciones principales de la aplicación.
    .DESCRIPTION
    Limpia la consola y despliega las cinco opciones exigidas por el proyecto más la opción de salida. No ejecuta lógica administrativa; solo presenta el menú.
    .OUTPUTS
    Texto escrito en consola.
    .EXAMPLE
    Show-MainMenu
    Imprime el menú principal.
    #>
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
    <#
    .SYNOPSIS
    Pausa la aplicación hasta que el usuario presione ENTER.
    .DESCRIPTION
    Se usa después de cada opción para que el usuario pueda leer la salida antes de regresar al menú principal.
    .OUTPUTS
    No devuelve objetos. Lee una entrada de consola.
    .EXAMPLE
    Pause-Screen
    Espera confirmación del usuario.
    #>
    Write-Host ""
    Read-Host "Presione ENTER para continuar"
}

function Write-SectionTitle {
    <#
    .SYNOPSIS
    Imprime un título de sección para una opción del menú.
    .DESCRIPTION
    Recibe un texto y lo presenta entre separadores. Los módulos funcionales lo usan para identificar claramente la salida de cada opción.
    .PARAMETER Title
    Texto que se imprimirá como título.
    .OUTPUTS
    Texto escrito en consola.
    .EXAMPLE
    Write-SectionTitle "Filesystems/discos conectados"
    Imprime el encabezado de la opción de discos.
    #>
    param (
        [string]$Title
    )

    Write-Host ""
    Write-Host "----------------------------------------------"
    Write-Host $Title
    Write-Host "----------------------------------------------"
}
