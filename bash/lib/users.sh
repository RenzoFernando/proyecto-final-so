get_last_login_for_user() {
    local username="$1"
    local login_line=""

    if command -v lastlog >/dev/null 2>&1; then
        login_line="$(LC_ALL=C lastlog -u "$username" 2>/dev/null | awk 'NR==2 {print}')"

        if [ -z "$login_line" ] || echo "$login_line" | grep -qi "Never logged in"; then
            echo "Nunca o sin registro"
            return
        fi

        login_line="${login_line#"$username"}"
        login_line="$(printf '%s' "$login_line" | sed 's/^[[:space:]]*//')"

        if [ -z "$login_line" ]; then
            echo "Nunca o sin registro"
        else
            echo "$login_line"
        fi

        return
    fi

    if command -v last >/dev/null 2>&1; then
        login_line="$(LC_ALL=C last -n 1 "$username" 2>/dev/null | awk 'NF > 0 && $0 !~ /wtmp begins/ {print; exit}')"

        if [ -z "$login_line" ]; then
            echo "Nunca o sin registro"
        else
            echo "$login_line"
        fi

        return
    fi

    echo "No disponible"
}

show_users_last_login() {
    print_section_title "Usuarios creados y último login"

    if [ ! -r /etc/passwd ]; then
        echo "No se pudo leer /etc/passwd."
        return 1
    fi

    printf "%-30s %s\n" "USUARIO" "ULTIMO_LOGIN"
    printf "%-30s %s\n" "-------" "------------"

    while IFS=: read -r username _; do
        if [ -n "$username" ]; then
            printf "%-30s %s\n" "$username" "$(get_last_login_for_user "$username")"
        fi
    done < /etc/passwd
}
