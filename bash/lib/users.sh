#!/bin/bash

# ==============================================================================
# Archivo: lib/users.sh
# Propósito:
#   Implementar la opción 1 del proyecto: usuarios creados y fecha de último login.
# Relación con el curso:
#   Usa archivos y comandos propios de Linux. /etc/passwd funciona como fuente de
#   usuarios locales, mientras lastlog, last, who o la sesión actual funcionan como
#   fuentes para consultar el ingreso del usuario.
# ==============================================================================

# get_uid_min
# Entrada:
#   No recibe parámetros.
# Salida:
#   Imprime el UID mínimo configurado para usuarios normales. Si no se puede leer,
#   imprime 1000 como valor por omisión frecuente en Linux.
# Descripción:
#   Evita listar cuentas internas del sistema. Se consulta /etc/login.defs cuando
#   existe porque algunas distribuciones pueden usar un UID mínimo distinto.
get_uid_min() {
    local uid_min=""

    if [ -r /etc/login.defs ]; then
        uid_min="$(awk '$1 == "UID_MIN" {print $2; exit}' /etc/login.defs)"
    fi

    if [ -z "$uid_min" ]; then
        uid_min=1000
    fi

    echo "$uid_min"
}

# get_created_users
# Entrada:
#   No recibe parámetros.
# Salida:
#   Imprime un usuario por línea.
# Descripción:
#   Lee la base local de usuarios mediante getent o /etc/passwd. Se consideran
#   usuarios interactivos root y usuarios con UID >= UID_MIN cuyo shell no sea
#   nologin ni false.
get_created_users() {
    local uid_min=""

    uid_min="$(get_uid_min)"

    if command -v getent > /dev/null 2>&1; then
        getent passwd
    else
        cat /etc/passwd
    fi | awk -F: -v uid_min="$uid_min" '
        ($3 == 0 || $3 >= uid_min) && $7 !~ /(nologin|false)$/ {
            print $1
        }
    ' | sort
}

# get_active_session_for_user
# Entrada:
#   $1: nombre del usuario.
# Salida:
#   Imprime información de sesión activa si el usuario está conectado.
# Descripción:
#   En WSL/Kali algunos registros históricos como lastlog o wtmp pueden no actualizarse.
#   Por eso se agrega una fuente de respaldo basada en who y en el usuario actual.
get_active_session_for_user() {
    local username="$1"
    local session_line=""
    local current_user=""
    local login_user=""

    if command -v who > /dev/null 2>&1; then
        session_line="$(who 2> /dev/null | awk -v user="$username" '
            $1 == user {
                $1="";
                sub(/^[[:space:]]+/, "");
                print "Sesión activa: " $0;
                exit
            }
        ')"

        if [ -n "$session_line" ]; then
            echo "$session_line"
            return 0
        fi
    fi

    current_user="$(id -un 2> /dev/null)"
    login_user="$(logname 2> /dev/null)"

    if [ "$username" = "$current_user" ] || [ "$username" = "$USER" ] || [ "$username" = "$login_user" ]; then
        echo "Sesión actual: $(date '+%Y-%m-%d %H:%M:%S')"
        return 0
    fi

    return 1
}

# get_last_login_for_user
# Entrada:
#   $1: nombre del usuario.
# Salida:
#   Imprime la fecha de último login, una sesión activa o un mensaje de ausencia.
# Descripción:
#   Intenta primero con lastlog, luego con last y finalmente con la sesión activa.
#   Esto corrige ambientes WSL/Kali donde lastlog puede decir Never aunque el usuario
#   actual esté ejecutando la herramienta.
get_last_login_for_user() {
    local username="$1"
    local login_line=""

    if command -v lastlog > /dev/null 2>&1; then
        login_line="$(lastlog -u "$username" 2> /dev/null | awk 'NR == 2 {$1=""; sub(/^[[:space:]]+/, ""); print}')"

        if [ -n "$login_line" ] && ! printf "%s" "$login_line" | grep -Eiq "never|nunca|jam[aá]s"; then
            echo "$login_line"
            return
        fi
    fi

    if command -v last > /dev/null 2>&1; then
        login_line="$(last -n 1 "$username" 2> /dev/null | awk 'NF > 0 && $0 !~ /wtmp begins/ {print; exit}')"

        if [ -n "$login_line" ]; then
            echo "$login_line"
            return
        fi
    fi

    if get_active_session_for_user "$username"; then
        return
    fi

    echo "Nunca o sin registro"
}

# show_users_last_login
# Entrada:
#   No recibe parámetros.
# Salida:
#   Imprime una tabla con usuario y último login.
# Descripción:
#   Coordina la consulta de usuarios y la consulta individual de último ingreso.
#   La salida se mantiene simple para poder sustentarse desde consola.
show_users_last_login() {
    local username=""

    print_section_title "Usuarios creados y último login"

    if [ ! -r /etc/passwd ]; then
        echo "No se pudo leer la lista de usuarios del sistema."
        return 1
    fi

    printf "%-30s %s\n" "Usuario" "UltimoLogin"
    printf "%-30s %s\n" "------------------------------" "------------------------------"

    get_created_users | while IFS= read -r username; do
        if [ -n "$username" ]; then
            printf "%-30s %s\n" "$username" "$(get_last_login_for_user "$username")"
        fi
    done
}
