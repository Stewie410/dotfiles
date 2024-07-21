#!/usr/bin/env bash
#
# simple cd-bookmarks

bm() {
    show_help() {
        cat << EOF
Simple 'cd' bookmarks

USAGE:  ${FUNCNAME[1]} [OPTIONS] [ACTION] BOOKMARK
        ${FUNCNAME[1]} [OPTIONS] edit|ls
        ${FUNCNAME[1]} [OPTIONS] rm BOOKMARK [...]
        ${FUNCNAME[1]} [OPTIONS] add|update PATH BOOKMARK

OPTIONS:
    -h, --help              Show this help message
    -c, --config PATH       Use PATH as config, overrides \$BM_CONFIG if set
                            (default: \$XDG_CONFIG_HOME/bm/marks.rc)

ACTIONS:
    <none>                  cd to BOOKMARK (default action)
    edit                    Open config file in \$EDITOR
    ls                      Print bookmarks to stdout
    rm                      Remove all specified BOOKMARK
    add, update PATH        Set BOOKMARK as PATH
EOF
    }

    is_defined() {
        [[ -n "${marks["$1"]}" ]] && return 0
        printf 'Bookmark is not defined: %s\n' "${1}" >&2
        return 1
    }

    real_path() {
        # TODO: realpath is not portable
        realpath --canonicalize-missing "${1}" && return 0
        printf 'Cannot parse path: %s\n' "${1}" >&2
        return 1
    }

    parse() {
        local k v
        while read -r k _ v; do
            [[ "${k}" =~ ^\s*(#.*)?$ ]] && continue
            marks["${k}"]="${v% #*}"
        done < "${config}"
    }

    show() {
        local k
        for k in "${!marks[@]}"; do
            printf '%s = %s\n' "${k}" "${marks["$k"]}"
        done
    }

    remove() {
        if [[ -z "${1}" ]]; then
            printf 'At least one bookmark must be specified\n' >&2
            return 1
        fi

        parse
        while (( $# > 0 )); do
            is_defined "${1}" && unset "marks[${1}]"
            shift
        done
        show > "${config}"
    }

    add() {
        if (( $# < 2 )); then
            printf 'Must specify both a PATH & BOOKMARK\n' >&2
            return 1
        fi

        parse
        marks["${2}"]="$(real_path "${1}")" || return 1
        show > "${config}"
    }

    local -A marks
    local config

    config="${BM_RC:-${XDG_CONFIG_HOME:-$HOME/.config}/bm/marks.rc}"

    case "${1}" in
        -h | --help )   show_help; return 0;;
        -c | --config ) config="$(real_path "${2}")" || return 1; shift 2;;
    esac

    mkdir --parents "${config%/*}"
    touch -a "${config}"

    case "${1,,}" in
        edit )          "${EDITOR:-editor}" "${config}" || return 1;;
        ls )            cat "${config}";;
        rm )            shift; remove "${@}" || return 1;;
        add | update )  shift; add "${@}" || return 1;;
        * )
            parse
            is_defined "${1}" || return 1
            cd "${marks["$1"]}" || return 1
            ;;
    esac
}

alias bml='bm ls'
alias bme='bm edit'
alias bma='bm add'
alias bmr='bm rm'
