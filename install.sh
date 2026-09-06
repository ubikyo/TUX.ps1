#!/bin/bash

MODULE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

readonly BACK_COLOR1="\[\e[48;5;22m\]"
readonly BACK_COLOR2="\[\e[48;5;28m\]"
readonly BACK_COLOR3="\[\e[48;5;34m\]"
readonly BACK_COLOR4="\[\e[48;5;0m\]"

readonly FORE_COLOR1="\[\e[38;5;255m\]"
readonly FORE_COLOR2="\[\e[38;5;22m\]"
readonly FORE_COLOR3="\[\e[38;5;28m\]"
readonly FORE_COLOR4="\[\e[38;5;34m\]"

readonly RESET="\[\e[0m\]"

# Change le prompt PS1
build_ps1() {
    PS1=""
    local separator=""
    if [ "$1" = "true" ]; then
        PS1="${BACK_COLOR1}${FORE_COLOR1}   "
        PS1+="${BACK_COLOR2}${FORE_COLOR2}"
        separator=""
    fi
    PS1+="${BACK_COLOR2}${FORE_COLOR1} \u "
    PS1+="${BACK_COLOR3}${FORE_COLOR3}${separator}"
    PS1+="${BACK_COLOR3}${FORE_COLOR1} \h "
    PS1+="${BACK_COLOR4}${FORE_COLOR4}${separator}"
    PS1+="${RESET} \w > "

}

change_ps1() {
    mkdir -p /etc/TUX
    printf 'TUX_NERD_FONTS=%s\n' "$TUX_NERD_FONTS" > /etc/TUX/tux_ps1.conf
    local nerd_ps1 plain_ps1
    build_ps1 true
    nerd_ps1="$PS1"
    build_ps1 false
    plain_ps1="$PS1"

    LINE=$(cat <<EOF
if [ -n "\$BASH_VERSION" ] && [[ \$- == *i* ]]; then
    if [ -r /etc/TUX/tux_ps1.conf ]; then
        source /etc/TUX/tux_ps1.conf
    fi
    if [ "\${TUX_NERD_FONTS:-true}" = "true" ]; then
        PS1='${nerd_ps1}'
    else
        PS1='${plain_ps1}'
    fi
fi
EOF
)

    files=()
    files+=("/etc/bash.bashrc")
    files+=("/etc/skel/.bashrc")
    files+=("/root/.bashrc")

    for dir in /home/*; do
        if [ -f "$dir/.bashrc" ]; then
            files+=("$dir/.bashrc")
        fi
    done

    for file in "${files[@]}"; do
        print_msg "OK" "PS1" "Modification of the PS1 prompt on $file"
        echo -e "\n$LINE" >> "$file"
    done

    printf "\n\n${COLOR_HIGHLIGHT_BG}"
    printf " Please restart your terminal to enabled the new prompt ${COLOR_RESET}"

}

# Configure le PS1
init_ps1() {
    if print_dialog "$SILENT" "Enable the PS1 prompt1" \
        "Replace the current prompt with TUX.ps1, using the MOTD colors."; then

        if [ "$SILENT" = "yes" ]; then printf "\n"; fi

        print_msg "OK" "PS1" "Modifying the PS1 prompt"
        change_ps1
    else
        print_msg "INFO" "PS1" "Skipping the PS1 prompt modification"
    fi
}

# Reuse the parent installer's choice, or ask when installing this module separately.
configure_nerd_fonts() {
    case "${TUX_NERD_FONTS:-}" in
        true|false) return 0 ;;
    esac
    if print_dialog "${SILENT:-no}" "Enable Nerd Font icons?" \
        "Display enhanced icons using Nerd Fonts. A compatible Nerd Font must be installed and selected in your terminal for the icons to display correctly."; then
        TUX_NERD_FONTS=true
    else
        TUX_NERD_FONTS=false
    fi
    export TUX_NERD_FONTS
}

main() {
    cd "$MODULE_DIR"

    configure_nerd_fonts

    print_header "Module PS1 installation\n"

    init_ps1

    cd ..
}

main "$@"
