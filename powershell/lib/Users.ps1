function Get-NetUserLastLogin {
    param (
        [string]$UserName
    )

    $netOutput = @(net user "$UserName" 2> $null)
    $loginLine = $netOutput | Where-Object { $_ -match "^(Last logon|Último inicio|Ultimo inicio)" } | Select-Object -First 1

    if ([string]::IsNullOrWhiteSpace($loginLine)) {
        return "No disponible con esta fuente"
    }

    $loginValue = ($loginLine -replace "^(Last logon|Último inicio de sesión|Ultimo inicio de sesion|Último inicio|Ultimo inicio)\s+", "").Trim()

    if ([string]::IsNullOrWhiteSpace($loginValue) -or $loginValue -match "Never|Nunca") {
        return "Nunca o sin registro"
    }

    return $loginValue
}

function Get-LocalUsersWithLastLogin {
    if (Get-Command Get-LocalUser -ErrorAction SilentlyContinue) {
        Get-LocalUser | Sort-Object -Property Name | Select-Object -Property @{
            Name = "Usuario"
            Expression = { $_.Name }
        }, @{
            Name = "UltimoLogin"
            Expression = {
                if ($_.LastLogon) {
                    $_.LastLogon
                } else {
                    "Nunca o sin registro"
                }
            }
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
                Expression = { Get-NetUserLastLogin -UserName $_.Name }
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
                    Expression = { Get-NetUserLastLogin -UserName $_.Name }
                }

            return
        } catch {
            throw "No se pudieron consultar los usuarios locales."
        }
    }
}

function Show-UsersLastLogin {
    Write-SectionTitle "Usuarios creados y último login"

    try {
        Get-LocalUsersWithLastLogin | Format-Table -AutoSize
    } catch {
        Write-Host $_
    }
}
