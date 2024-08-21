#!/usr/bin/env bash
#
# Install dotfiles

show_help() {
    cat << EOF
Install dotfiles

USAGE: ${0##*/} [OPTIONS] MODULE [...]

OPTIONS:
    -h, --help      Show this help message
EOF
}

require() {
    command -v "${1}" &>/dev/null && return 0
    printf 'Missing required application: %s\n' "${1}" >&2
    return 1
}

find_modules() {
    local -a list

    while (( $# > 0 )); do
        mapfile -tO "${#list[@]}" list < <(find "${0##*/}" \
            -maxdepth 1 -type d -iname "${1}" -printf '%p\n' 2>/dev/null \
        )
        shift
    done

    printf '%s\n' "${list[@]}" | awk '!seen[$0]++'
}

# yq_parse(module, &array)
parse_config() {
    local -n arr="${2}"
    local k v is_wsl

    [[ -n "${WSL_INTEROP}" ]] && is_wsl="1"

    while read -r k _ v; do
        # shellcheck disable=SC2034
        arr["${k}"]="${v}"
    done < <(awk --assign "WSL=${is_wsl:-0}" '
        function platform_compat(platform) {
            if (WSL == 1)
                return platform == "wsl"
            return platform == "linux"
        }

        function expand(string,    name) {
            while (match(string, /\$\{\{ [^\s]+? \}\}/) > 0) {
                name = gensub(/\$\{\{ ([^\s]+? \}\}/, "\\1", 1, string))
                string = gensub(/\$\{\{ [^\s]+? \}\}/, ENVIRON[name], 1, string)
            }

            return string
        }

        function trim(string, ch) {
            return gensub("^" ch "|" ch "$", "", "G", string)
        }

        function get_key(string) {
            return gensub(/^\s*([^:]+?):.*/, "\\1", 1, string)
        }

        function get_val(string) {
            return gensub(/^[^:]+?:\s*/, "", 1, string)
        }

        /^[^:]+?:\s+$/ {
            item = get_key($0)
            next
        }

        /^.*?: (.+/?)+/ {
            key = get_key($0)
            val = trim(expand(get_val($0)), "\"")
            if (platform_compat(key))
                print key "." item " = " val
        }
    ' "${1}")
}

install_module() {
    local repo k err
    local -A config

    if ! [[ -s "${1}/dots.yml" ]]; then
        printf 'No yaml (config) in module: %s\n' "${1##*/}" >&2
        return 1
    fi

    parse_config "${repo}/dots.yml" config || return 1
    if (( ${#config[@]} == 0 )); then
        printf 'No compatible paths in config.\n' >&2
        return 1
    fi

    for k in "${!config[@]}"; do
        printf 'Installing %s: ' "${1##*/}/${k}"
        if ln --symbolic --force "${1}/${k#*.}" "${config["${k}"]}"; then
            printf '[%s%s%s]\n' $'\e[31m' "FAIL" $'\e[0'
            err="1"
        else
            printf '[%s%s%s]\n' $'\e[32m' 'OK' $'\e[0'
        fi
    done

    return "${err:-0}"
}

main() {
    local -a modules
    local opts err
    opts="$(getopt \
        --options h \
        --longoptions help \
        --name "${0##*/}" \
        -- "${@}" \
    )"

    eval set -- "${opts}"
    while true; do
        case "${1}" in
            -h | --help )       show_help; return 0;;
            -- )                shift; break;;
            * )                 break;;
        esac
        shift
    done

    [[ -z "${XDG_CONFIG_HOME}" ]] && XDG_CONFIG_HOME="${HOME}/.config"

    mapfile -t modules < <(find_modules "${@}")
    if (( ${#modules[@]} == 0 )); then
        printf 'Cannot locate matching module: %s\n' "${*}" >&2
        return 1
    fi

    set -- "${modules[@]}"
    while (( $# > 0 )); do
        install_module "${1}" || err="1"
        shift
    done

    return "${err:-0}"
}

main "${@}"
