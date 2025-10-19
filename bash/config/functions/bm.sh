#!/usr/bin/env bash
#
# simple cd-bookmarks

bm() {
    show_help() {
        cat <<EOF
Simple 'cd' bookmarks

USAGE:  ${FUNCNAME[1]} [OPTIONS] [COMMAND] MARK

OPTIONS:
    -h, --help              Show this help message
    -c, --config PATH       Use PATH as config, overrides \$BM_CONFIG if set
                            (default: \$XDG_CONFIG_HOME/bm/marks.rc)

ACTIONS:
    [cd]                    cd to BOOKMARK (default action)
    pushd                   pushd to MARK
    edit                    Open config file in \$EDITOR
    ls                      Print bookmarks to stdout
    rm                      Remove all specified BOOKMARK
    add PATH                Set BOOKMARK as PATH
EOF
    }

    _real() {
        # TODO: realpath is not portable
        realpath --canonicalize-missing "${1}" && return 0
        printf 'Cannot parse path: %s\n' "${1}" >&2
        return 1
    }

    _show() {
        local k
        for k in "${!marks[@]}"; do
            printf '%s = %s\n' "${k}" "${marks["$k"]}"
        done
    }

    _parse() {
        local k v
        while read -r k _ v; do
            [[ "${k}" == "#"* ]] && continue
            marks["${k}"]="${v% #*}"
        done <"${1}"
    }

    _rm() {
        if (($# == 0)); then
            printf 'Must specify at least one MARK to remove\n' >&2
            return 1
        fi

        while (($# > 0)); do
            unset "marks[${1}]" &>/dev/null
            shift
        done

        _show >"${config}"
    }

    _add() {
        if (($# < 2)); then
            printf 'Must specify a MARK for PATH\n' >&2
            return 1
        fi

        marks["${2}"]="$(_real "${1}")" || return 1
        _show >"${config}"
    }

    _nav() {
        [[ "${1,,}" != "cd" && "${1,,}" != "pushd" ]] &&
            set -- "cd" "${@}"

        if (($# == 1)); then
            printf 'Must specify MARK\n' >&2
            return 1
        elif [[ -z "${marks["$2"]}" ]]; then
            printf 'MARK not defined: %s\n' "${2}" >&2
            return 1
        fi

        "${1}" "${marks["$2"]}" || return 1
    }

    local -A marks
    local k v config

    config="${XDG_CONFIG_HOME:-$HOME/.config}/bm/marks.rc"

    if [[ "${1}" == "-h" || "${1}" == "--help" ]]; then
        show_help
        return 0
    elif [[ "${1}" == "-c" || "${1}" == "--config" ]]; then
        config="$(_real "${2}")" || return 1
        shift 2
    fi

    mkdir --parents "${config%/*}"
    touch -a "${config}"
    _parse "${config}"

    case "${1,,}" in
    edit) "${EDITOR:-editor}" "${config}" || return 1 ;;
    ls) cat "${config}" ;;
    rm) _rm "${@:2}" || return 1 ;;
    add) _add "${@:2}" || return 1 ;;
    *) _nav "${@}" || return 1 ;;
    esac

    return 0
}
