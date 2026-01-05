#!/usr/bin/env bash
#
# CD, but with bookmarks/aliases
# TODO: Use zoxide like everyone else

bm() {
    _usage() {
        cat <<EOF
Simple 'cd' bookmarks

USAGE:  bm [OPTIONS] [cd]|pushd MARK[/PATH]
        bm [OPTIONS] edit
        bm [OPTIONS] [ls]
        bm [OPTIONS] rm MARK [MARK [...]]
        bm [OPTIONS] add PATH MARK

OPTIONS:
    -h, --help              Show this help message
    -c, --config PATH       Use PATH as config, overrides \$BM_CONFIG if set
                            (default: \$XDG_CONFIG_HOME/bm/marks.rc)
EOF
    }

    _err() {
        printf '\e[0;31mERROR\e[0m: %s\n' "${@}" >&2
    }

    _defined() {
        [[ -n "${marks["$1"]+x}" ]] && return 0
        _err "Mark is not defined: ${1}"
        return 1
    }

    _real() {
        readlink --canonicalize-missing "${1}" 2>/dev/null && return 0
        _err "Cannot parse path: ${1}"
        return 1
    }

    _parse() {
        local k v
        while read -r k _ v; do
            marks["${k}"]="${v% #*}"
        done < "${config}"
    }

    _fmt() {
        local k
        for k in "${!marks[@]}"; do
            printf '%s = %s\n' "${k}" "${marks["$k"]}"
        done
    }

    local -A marks
    local opts config
    config="${XDG_CONFIG_HOME:-$HOME/.config}/bookmarks/bm.rc"
    opts="$(getopt \
        --options hc: \
        --longoptions help,config: \
        --name 'bm' \
        -- "${@}" \
    )"

    eval set -- "${opts}"
    while true; do
        case "${1}" in
            -h | --help )       _usage; return 0;;
            -c | --config )     config="${2}"; shift;;
            -- )                shift; break;;
            * )                 break;;
        esac
        shift
    done

    config="$(_real "${config}")" || return 1
    mkdir --parents "${config%/*}"
    touch -a "${config}"

    set -- "${1:-default}" "${@:2}"

    case "${1,,}" in
        edit )
            "${EDITOR:-editor}" "${config}" || return 1
            ;;
        ls | default )
            cat "${config}"
            ;;
        rm )
            shift
            if (( $# == 0 )); then
                _err "Must specify at least one MARK"
                return 1
            fi

            _parse
            local count
            while (( $# > 0 )); do
                _defined "${1}" && unset "marks[${1}]"
                if _defined "${1}"; then
                    unset "marks[${1}]"
                else
                    (( count++ ))
                fi
                shift
            done
            _fmt > "${config}"
            (( count == 0 )) || return 1
            ;;
        add )
            shift
            if (( $# != 2 )); then
                _err "Must specify both PATH and MARK"
                return 1
            fi

            _parse
            marks["${2}"]="$(_real "${1}")" || return 1
            _fmt > "${config}"
            ;;
        pushd )
            shift
            if (( $# == 0 )); then
                _err "Must specify a MARK"
                return 1
            fi

            _parse
            if [[ "${1}" == *"/"* ]]; then
                _defined "${1%%/*}" || return 1
                pushd "${marks["${1%%/*}"]}/${1#*/}" || return 1
            else
                _defined "${1}" || return 1
                pushd "${marks["$1"]}" || return 1
            fi
            ;;
        * )
            [[ ",cd,nav," == *",${1,,},"* ]] && shift
            if (( $# == 0 )); then
                _err "Must specify a MARK"
                return 1
            fi

            _parse
            if [[ "${1}" == *"/"* ]]; then
                _defined "${1%%/*}" || return 1
                cd "${marks["${1%%/*}"]}/${1#*/}" || return 1
            else
                _defined "${1}" || return 1
                cd "${marks["$1"]}" || return 1
            fi
            ;;
    esac

    return 0
}

alias bmw='bm --config "${HOME}/.config/bookmarks/work.rc"'
