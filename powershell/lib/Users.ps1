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
                Expression = { "No disponible con esta fuente" }
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
                    Expression = { "No disponible con esta fuente" }
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
