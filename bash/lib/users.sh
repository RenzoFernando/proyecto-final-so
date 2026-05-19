show_users_last_login() {
    print_section_title "Usuarios creados y último login"

    if [ ! -r /etc/passwd ]; then
        echo "No se pudo leer la lista de usuarios del sistema."
        return 1
    fi

    if ! command -v lastlog > /dev/null 2>&1; then
        echo "No se encontró el comando lastlog para consultar el último login."
        return 1
    fi

    printf "%-30s %s\n" "Usuario" "UltimoLogin"
    printf "%-30s %s\n" "------------------------------" "------------------------------"

    if command -v getent > /dev/null 2>&1; then
        user_source="$(getent passwd | awk -F: '{print $1}')"
    else
        user_source="$(awk -F: '{print $1}' /etc/passwd)"
    fi

    printf "%s\n" "$user_source" | while IFS= read -r username; do
        if [ -n "$username" ]; then
            login_line="$(lastlog -u "$username" 2> /dev/null | awk 'NR==2 {print}')"

            if [ -z "$login_line" ] || printf "%s" "$login_line" | grep -qi "never"; then
                last_login="Nunca o sin registro"
            else
                last_login="$(printf "%s" "$login_line" | sed "s/^$username[[:space:]]*//")"

                if [ -z "$last_login" ]; then
                    last_login="Nunca o sin registro"
                fi
            fi

            printf "%-30s %s\n" "$username" "$last_login"
        fi
    done
}
