<#
.SYNOPSIS
Consulta usuarios locales y fecha de último login.
.DESCRIPTION
Implementa la opción 1 del proyecto. Usa Get-LocalUser cuando está disponible porque entrega directamente la propiedad LastLogon. Si el cmdlet no existe, usa Win32_UserAccount con CIM o WMI y complementa la fecha mediante net user.
#>

function Get-NetUserLastLogin {
    <#
    .SYNOPSIS
    Obtiene el último login de un usuario local mediante net user.
    .DESCRIPTION
    Sirve como fuente auxiliar para versiones donde Get-LocalUser no está disponible o no entrega la información requerida. El análisis contempla salidas comunes en inglés y español.
    .PARAMETER UserName
    Nombre del usuario local que se consultará.
    .OUTPUTS
    Cadena de texto con la fecha de último login o un mensaje de no disponibilidad.
    .EXAMPLE
    Get-NetUserLastLogin -UserName "usuario"
    Consulta el último inicio de sesión del usuario indicado.
    #>
    param (
        [string]$UserName
    )

    $netOutput = @(net user "$UserName" 2> $null)
    $loginLine = $netOutput | Where-Object { $_ -match "^(Last logon|Último inicio|Ultimo inicio)" } | Select-Object -First 1

    if ([string]::IsNullOrWhiteSpace($loginLine)) {
        return "Sin registro disponible"
    }

    $loginValue = ($loginLine -replace "^(Last logon|Último inicio de sesión|Ultimo inicio de sesion|Último inicio|Ultimo inicio)\s+", "").Trim()

    if ([string]::IsNullOrWhiteSpace($loginValue) -or $loginValue -match "Never|Nunca") {
        return "Nunca o sin registro"
    }

    return $loginValue
}

function Get-QuserLastLogin {
    param (
        [string]$UserName
    )

    try {
        $userPattern = "^" + [regex]::Escape($UserName) + "\s+"
        $sessionLines = @(quser 2> $null)

        foreach ($line in $sessionLines) {
            $sessionLine = ($line -replace "^\s*>?\s*", "").Trim()

            if ($sessionLine -match $userPattern) {
                $columns = $sessionLine -split "\s{2,}"
                $logonTime = $columns[$columns.Count - 1].Trim()

                if (-not [string]::IsNullOrWhiteSpace($logonTime) -and $logonTime -notmatch "LOGON TIME|TIEMPO") {
                    return "Sesión activa desde $logonTime"
                }
            }
        }

        return ""
    } catch {
        return ""
    }
}

function Get-UserLastLogin {
    param (
        [string]$UserName,
        [object]$LastLogon
    )

    if ($null -ne $LastLogon -and -not [string]::IsNullOrWhiteSpace($LastLogon.ToString())) {
        return $LastLogon
    }

    $netLogin = Get-NetUserLastLogin -UserName $UserName

    if ([string]::IsNullOrWhiteSpace($netLogin) -or $netLogin -eq "Nunca o sin registro" -or $netLogin -eq "Sin registro disponible") {
        $sessionLogin = Get-QuserLastLogin -UserName $UserName

        if (-not [string]::IsNullOrWhiteSpace($sessionLogin)) {
            return $sessionLogin
        }
    }

    if ([string]::IsNullOrWhiteSpace($netLogin)) {
        return "Sin registro disponible"
    }

    return $netLogin
}

function Get-LocalUsersWithLastLogin {
    <#
    .SYNOPSIS
    Devuelve usuarios locales con último login conocido.
    .DESCRIPTION
    Intenta tres rutas de consulta en orden: Get-LocalUser, CIM sobre Win32_UserAccount y WMI sobre Win32_UserAccount. De esta manera la opción funciona en distintas versiones de Windows PowerShell.
    .OUTPUTS
    Objetos con propiedades Usuario y UltimoLogin.
    .EXAMPLE
    Get-LocalUsersWithLastLogin
    Genera la lista de usuarios locales con último ingreso.
    #>
    if (Get-Command Get-LocalUser -ErrorAction SilentlyContinue) {
        Get-LocalUser | Sort-Object -Property Name | Select-Object -Property @{
            Name = "Usuario"
            Expression = { $_.Name }
        }, @{
            Name = "UltimoLogin"
            Expression = { Get-UserLastLogin -UserName $_.Name -LastLogon $_.LastLogon }
        }

        return
    }

    try {
        Get-CimInstance -ClassName Win32_UserAccount -Filter "LocalAccount=True" -ErrorAction Stop |
            Sort-Object -Property Name |
            Select-Object -Property @{
                Name = "Usuario"
                Expression = { $_.Name }
            }, @{
                Name = "UltimoLogin"
                Expression = { Get-UserLastLogin -UserName $_.Name -LastLogon $null }
            }

        return
    } catch {
        try {
            Get-WmiObject -Class Win32_UserAccount -Filter "LocalAccount=True" -ErrorAction Stop |
                Sort-Object -Property Name |
                Select-Object -Property @{
                    Name = "Usuario"
                    Expression = { $_.Name }
                }, @{
                    Name = "UltimoLogin"
                    Expression = { Get-UserLastLogin -UserName $_.Name -LastLogon $null }
                }

            return
        } catch {
            throw "No se pudieron consultar los usuarios locales."
        }
    }
}

function Show-UsersLastLogin {
    <#
    .SYNOPSIS
    Muestra usuarios locales y último login en formato de tabla.
    .DESCRIPTION
    Es la función llamada desde el menú. Encapsula la presentación de la opción 1 y captura errores para que la aplicación no se cierre abruptamente.
    .OUTPUTS
    Tabla escrita en consola.
    .EXAMPLE
    Show-UsersLastLogin
    Muestra la opción 1 del proyecto.
    #>
    Write-SectionTitle "Usuarios creados y último login"

    try {
        Get-LocalUsersWithLastLogin | Format-Table -AutoSize
    } catch {
        Write-Host $_
    }
}
