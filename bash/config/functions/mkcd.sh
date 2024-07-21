#!/usr/bin/env bash
#
# make and change directory

mkcd() {
    real_path() {
        # TODO: realpath is not portable
        realpath --canonicalize-missing "${1}" && return 0
        printf 'Cannot resolve path: %s\n' "${1}" >&2
        return 1
    }

    if [[ -z "${1}" ]]; then
        printf 'No path specified\n' >&2
        return 1
    elif [[ "${1}" == "-h" || "${1}" == "--help" ]]; then
        cat << EOF
Make and change directory

USAGE: ${FUNCNAME[0]} [-h|--help] PATH
EOF
        return 0
    fi

    local p
    p="$(real_path "${1}")" || return 1

    mkdir --parents "${p}" || return 1
    cd "${p}" || return 1
}

mdod() {
    if [[ -z "${1}" ]]; then
        printf 'Date string must be specified\n' >&2
        return 1
    elif [[ "${1}" == "-h" || "${1}" == "--help" ]]; then
        cat << EOF
Make and change to DATE's working directory

USAGE: ${FUNCNAME[0]} [-h|--help] DATE
EOF
        return 0
    fi

    local d
    d="$(date --date="${1}" --iso-8601)"

    mkcd "${WORKING_DIR:-$HOME/working}/${d}"
}

alias mdot='mdod today'
alias mdoy='mdod yesterday'
